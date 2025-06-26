//
//  TaskListIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

final class TaskListPresenter: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var filteredTasks: [TaskEntity] = []
    @Published var searchQuery: String = "" {
        didSet { filterTasks() }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedTaskId: UUID?
    @Published var showDeleteConfirmation: Bool = false
    @Published var taskToDelete: UUID?
    @Published var isSearchVisible: Bool = false
    
    let userId: String
    
    private let interactor: TaskListInteractor
    private let router: TaskListRouter
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: TaskListInteractor, router: TaskListRouter, userId: String) {
        self.interactor = interactor
        self.router = router
        self.userId = userId
    }
    
    func viewDidAppear() {
        selectedTaskId = nil
        loadTasks()
    }
    func loadTasks() {
        isLoading = true
        interactor.fetchAllTasks(for: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] taskList in
                self?.tasks = taskList
                self?.filterTasks()
            })
            .store(in: &cancellables)
    }
    func filterTasks() {
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter {
                $0.title.lowercased().contains(query) ||
                $0.descriptionText.lowercased().contains(query)
            }
        }
    }
    func onAddTaskTapped() {
        router.navigateToAddTask(userId: userId, onTasksUpdated: { [weak self] in
            self?.loadTasks()
        })
    }
    func onEditTaskTapped(_ task: TaskEntity) {
        router.navigateToEditTask(task: task, onTasksUpdated: { [weak self] in
            self?.loadTasks()
        })
    }
    func onDeleteTaskTapped(_ id: UUID) {
        showDeleteConfirmation = true
        taskToDelete = id
    }
    func confirmDeleteTask() {
        guard let id = taskToDelete else { return }
        isLoading = true
        interactor.deleteTask(id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.loadTasks()
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    func onSetAsPriorityTapped(_ task: TaskEntity) {
        isLoading = true
        interactor.setTaskAsPriority(task)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.loadTasks()
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
    func onTaskSelected(_ task: TaskEntity) {
        selectedTaskId = task.id
        onEditTaskTapped(task)
    }
    func onDismissErrorTapped() {
        errorMessage = nil
    }
}
