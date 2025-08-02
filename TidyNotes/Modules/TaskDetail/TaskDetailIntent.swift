//
//  TaskDetailIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import Foundation
import Combine
import SwiftUI

final class TaskDetailPresenter: ObservableObject {
    @Published var task: TaskEntity
    @Published var taskModel: TaskModel
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showDatePicker: Bool = false
    @Published var showReminderPicker: Bool = false
    @Published var selectedImage: UIImage?
    @Published var isTaskChanged: Bool = false

    private let interactor: TaskDetailInteractor
    private let router: TaskDetailRouter
    private var originalTask: TaskEntity?
    private var cancellables = Set<AnyCancellable>()
    
    let mode: Mode

    enum Mode { case create, edit }

    init(
        task: TaskEntity,
        interactor: TaskDetailInteractor,
        router: TaskDetailRouter,
        mode: Mode
    ) {
        self.task = task
        self.taskModel = TaskModel(entity: task)
        self.interactor = interactor
        self.router = router
        self.mode = mode
        if mode == .edit {
            originalTask = TaskEntity(
                id: task.id,
                userId: task.userId,
                title: task.title,
                descriptionText: task.descriptionText,
                isPriority: task.isPriority,
                createdAt: task.createdAt,
                dueDate: task.dueDate,
                isReminderOn: task.isReminderOn,
                reminderDate: task.reminderDate,
                imagePath: task.imagePath,
                status: task.status
            )
        }
    }

    func viewDidLoad(taskId: UUID?) {
        guard mode == .edit, let taskId else { return }
        isLoading = true
        interactor.fetchTask(by: taskId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let err) = completion {
                    self?.showError(message: err.localizedDescription)
                }
            }, receiveValue: { [weak self] fetched in
                if let fetched = fetched {
                    self?.task = fetched
                    self?.originalTask = TaskEntity(
                        id: fetched.id,
                        userId: fetched.userId,
                        title: fetched.title,
                        descriptionText: fetched.descriptionText,
                        isPriority: fetched.isPriority,
                        createdAt: fetched.createdAt,
                        dueDate: fetched.dueDate,
                        isReminderOn: fetched.isReminderOn,
                        reminderDate: fetched.reminderDate,
                        imagePath: fetched.imagePath,
                        status: fetched.status
                    )
                    
                    self?.taskModel = TaskModel(entity: fetched)
                } else {
                    self?.showError(message: "Task not found")
                }
            })
            .store(in: &cancellables)
    }

    func onTitleChanged(_ newValue: String) {
        taskModel.title = newValue
        checkIfChanged()
    }
    func onDescChanged(_ newValue: String) {
        taskModel.descriptionText = newValue
        checkIfChanged()
    }
    func onDueDateChanged(_ newValue: Date?) {
        taskModel.dueDate = newValue
        checkIfChanged()
    }
    func onPriorityChanged(_ newValue: Bool) {
        taskModel.isPriority = newValue
        checkIfChanged()
    }
    func onStatusChanged(_ newValue: TaskStatus) {
        taskModel.status = newValue
        checkIfChanged()
    }
    func onReminderChanged(_ on: Bool, date: Date?) {
        taskModel.isReminderOn = on
        taskModel.reminderDate = on ? (date ?? Calendar.current.date(byAdding: .minute, value: 15, to: Date())) : nil
        checkIfChanged()
    }
    func setImage(_ image: UIImage) {
        selectedImage = image
        if let path = saveImageToDisk(image) {
            taskModel.imagePath = path
            checkIfChanged()
        }
    }

    // Save ke DB
    func saveTask() {
        isLoading = true
        let entityData = taskModel.toEntity()
        let pub: AnyPublisher<Void, Error> = (mode == .create)
        ? interactor.createTask(entityData).map { _ in }.eraseToAnyPublisher()
        : interactor.saveTask(entityData)
        
        pub
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let userId = self?.task.userId else {
                    return Fail(error: AppError.userNotLoggedIn).eraseToAnyPublisher()
                }
                // ✅ Refresh data dari Cloud setelah save task sukses
                return self?.interactor.refreshLocalTasksFromCloud(userId: userId) ??
                Fail(error: AppError.unknown).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] comp in
                self?.isLoading = false
                if case .failure(let err) = comp {
                    self?.showError(message: err.localizedDescription)
                } else {
                    // ✅ Refresh task list ketika selesai
                    self?.router.dismissAndRefreshTaskList()
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    private func checkIfChanged() {
        if let ori = originalTask, mode == .edit {
            isTaskChanged = !isEqual(task, ori)
        } else {
            isTaskChanged = !taskModel.title.trimmed.isEmpty
        }
    }

    private func isEqual(_ t1: TaskEntity, _ t2: TaskEntity) -> Bool {
        t1.title == t2.title &&
        t1.descriptionText == t2.descriptionText &&
        t1.isPriority == t2.isPriority &&
        t1.dueDate == t2.dueDate &&
        t1.status == t2.status &&
        t1.isReminderOn == t2.isReminderOn &&
        t1.reminderDate == t2.reminderDate &&
        t1.imagePath == t2.imagePath
    }

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    private func saveImageToDisk(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("❌ Gagal simpan gambar: \(error)")
            return nil
        }
    }
}
