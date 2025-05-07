//
//  TaskDetailIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import Foundation
import Combine

final class TaskDetailPresenter: ObservableObject {
    @Published var noteContent: String = ""
    @Published var isNoteChanged: Bool = false
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    private let interactor: TaskDetailInteractor
    private let router: TaskDetailRouter
    private let taskId: UUID
    private var currentTask: TaskEntity?
    private var originalContent: String = ""
    private var cancellables = Set<AnyCancellable>()

    init(taskId: UUID, interactor: TaskDetailInteractor, router: TaskDetailRouter) {
        self.taskId = taskId
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        fetchTask()
    }

    func noteContentChanged(_ newValue: String) {
        noteContent = newValue
        isNoteChanged = newValue.trimmed != originalContent
    }

    func saveNote() {
        guard let task = currentTask else { return }
        interactor.updateTaskNoteContent(task: task, content: noteContent)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: updateTask(_:))
            .store(in: &cancellables)
    }

    func dismiss() {
        router.dismissTaskDetail()
    }

    private func fetchTask() {
        isLoading = true
        interactor.fetchTask(taskId: taskId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.showError(message: error.localizedDescription)
                }
            }, receiveValue: { [weak self] task in
                self?.currentTask = task
                self?.noteContent = task.description
                self?.originalContent = task.description
                self?.lastUpdated = task.dueDate // atau createdAt jika lebih cocok
                self?.isNoteChanged = false
            })
            .store(in: &cancellables)
    }

    private func updateTask(_ task: TaskEntity) {
        currentTask = task
        originalContent = task.description
        lastUpdated = task.dueDate
        isNoteChanged = false
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
        guard let lastUpdated = lastUpdated else { return "Belum pernah diperbarui" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: lastUpdated)
    }
}
