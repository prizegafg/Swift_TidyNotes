//
//  TaskDetailIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import Foundation
import Combine

final class TaskDetailPresenter: ObservableObject {
    enum Mode {
        case create
        case edit
    }
    
    @Published var taskTitle: String = ""
    @Published var noteContent: String = ""
    @Published var dueDate: Date = Date()
    @Published var hasDueDate: Bool = false
    @Published var isPriority: Bool = false
    @Published var taskStatus: TaskStatus = .todo
    @Published var isTaskChanged: Bool = false
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showDatePicker: Bool = false
    
    private let interactor: TaskDetailInteractor
    private let router: TaskDetailRouter
    private let taskId: UUID?
    private var currentTask: TaskEntity?
    private var originalTitle: String = ""
    private var originalContent: String = ""
    private var originalDueDate: Date?
    private var originalHasDueDate: Bool = false
    private var originalIsPriority: Bool = false
    private var originalStatus: TaskStatus = .todo
    private var cancellables = Set<AnyCancellable>()
    
    let mode: Mode
    
    deinit {
        print("TaskDetailPresenter deinit")
        cancellables.forEach { $0.cancel() }
    }
    // Initializer untuk mode edit
    init(taskId: UUID, interactor: TaskDetailInteractor, router: TaskDetailRouter) {
        self.taskId = taskId
        self.interactor = interactor
        self.router = router
        self.mode = .edit
    }
    
    // Initializer untuk mode create
    init(interactor: TaskDetailInteractor, router: TaskDetailRouter) {
        self.taskId = nil
        self.interactor = interactor
        self.router = router
        self.mode = .create
        
        // Atur nilai default untuk task baru
        self.taskTitle = ""
        self.noteContent = ""
        self.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        self.hasDueDate = false
        self.isPriority = false
        self.taskStatus = .todo
    }
    
    func viewDidLoad() {
        if mode == .edit, let taskId = taskId {
            fetchTask(taskId: taskId)
        } else {
            // Untuk mode create, set isTaskChanged = true agar tombol Save aktif
            isTaskChanged = true
        }
    }
    
    func titleChanged(_ newValue: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.taskTitle = newValue
            self.checkIfTaskChanged()
        }
    }
    
    func noteContentChanged(_ newValue: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.noteContent = newValue
            self.checkIfTaskChanged()
        }
    }
    
    func dueDateChanged(_ newValue: Date) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dueDate = newValue
            self.checkIfTaskChanged()
        }
    }
    
    func hasDueDateChanged(_ newValue: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hasDueDate = newValue
            self.checkIfTaskChanged()
        }
    }
    
    func priorityChanged(_ newValue: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPriority = newValue
            self.checkIfTaskChanged()
        }
    }
    
    func statusChanged(_ newValue: TaskStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.taskStatus = newValue
            self.checkIfTaskChanged()
        }
    }
    
    func toggleDatePicker() {
        showDatePicker.toggle()
    }
    
    private func checkIfTaskChanged() {
        if mode == .create {
            // Dalam mode create, isTaskChanged akan true jika judul tidak kosong
            isTaskChanged = !taskTitle.trimmed.isEmpty
        } else {
            // Dalam mode edit, check perubahan seperti biasa
            isTaskChanged = taskTitle.trimmed != originalTitle ||
                           noteContent.trimmed != originalContent ||
                           hasDueDate != originalHasDueDate ||
                           (hasDueDate && originalHasDueDate &&
                            !Calendar.current.isDate(dueDate, inSameDayAs: originalDueDate ?? Date())) ||
                           isPriority != originalIsPriority ||
                           taskStatus != originalStatus
        }
    }
    
    func saveTask() {
        if mode == .create {
            createNewTask()
        } else {
            updateExistingTask()
        }
        dismiss()
    }
    
    private func createNewTask() {
        isLoading = true
        
        interactor.createTask(
            title: taskTitle.trimmed,
            description: noteContent.trimmed,
            isPriority: isPriority,
            dueDate: hasDueDate ? dueDate : nil,
            status: taskStatus
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            self?.isLoading = false
            if case .failure(let error) = completion {
                self?.showError(message: error.localizedDescription)
            }
        }, receiveValue: { [weak self] task in
            self?.router.dismissAndRefreshTaskList()
        })
        .store(in: &cancellables)
        
    }
    
    private func updateExistingTask() {
        guard var task = currentTask else { return }
        
        task.title = taskTitle.trimmed
        task.description = noteContent.trimmed
        task.dueDate = hasDueDate ? dueDate : nil
        task.status = taskStatus
        task.isPriority = isPriority
        
        isLoading = true
        interactor.updateTask(task: task)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.showError(message: error.localizedDescription)
                }
            }, receiveValue: { [weak self] task in
                self?.updateTask(task)
            })
            .store(in: &cancellables)
    }
    
    func dismiss() {
        router.dismissTaskDetail()
    }
    
    private func fetchTask(taskId: UUID) {
        isLoading = true
        interactor.fetchTask(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.showError(message: error.localizedDescription)
                }
            }, receiveValue: { [weak self] task in
                self?.updateTaskFields(task)
            })
            .store(in: &cancellables)
    }
    
    private func updateTaskFields(_ task: TaskEntity) {
        currentTask = task
        taskTitle = task.title
        noteContent = task.description
        hasDueDate = task.dueDate != nil
        if let taskDueDate = task.dueDate {
            dueDate = taskDueDate
        }
        isPriority = task.isPriority
        taskStatus = task.status
        
        // Store original values
        originalTitle = task.title
        originalContent = task.description
        originalDueDate = task.dueDate
        originalHasDueDate = task.dueDate != nil
        originalIsPriority = task.isPriority
        originalStatus = task.status
        
        lastUpdated = task.createdAt
        isTaskChanged = false
    }
    
    private func updateTask(_ task: TaskEntity) {
        updateTaskFields(task)
    }
    
    private func handleError(_ completion: Subscribers.Completion<Error>) {
        if case let .failure(error) = completion {
            showError(message: error.localizedDescription)
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    var lastUpdatedFormatted: String {
        guard let lastUpdated = lastUpdated else { return "Never been updated" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: lastUpdated)
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: dueDate)
    }
    
    var statusOptions: [TaskStatus] {
        return [.todo, .inProgress, .done]
    }
    
    var navigationTitle: String {
        return mode == .create ? "Add Task" : "Task Detail"
    }
    
    var saveButtonTitle: String {
        return mode == .create ? "Add" : "Save"
    }
}
