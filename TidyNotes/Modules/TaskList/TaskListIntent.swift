//
//  TaskListIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

final class TaskListPresenter: ObservableObject {
    @Published var tasks: [TaskModel] = []
    @Published var filteredTasks: [TaskModel] = []
    @Published var searchQuery: String = "" {
        didSet { filterTasks() }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedTaskId: UUID?
    @Published var pendingDeleteTaskId: UUID? = nil
    @Published var showDeleteConfirmation: Bool = false
    @Published var taskToDelete: UUID?
    @Published var isSearchVisible: Bool = false
    @Published var userProfile: UserProfileEntity?

    
    let userId: String
    
    private let interactor: TaskListInteractor
    private let router: TaskListRouter
    private var cancellables = Set<AnyCancellable>()
    
    init(interactor: TaskListInteractor, router: TaskListRouter, userId: String) {
        self.interactor = interactor
        self.router = router
        self.userId = userId
        self.userProfile = UserProfileService.loadProfileFromLocal(userId: userId)
    }
    
    func viewDidAppear() {
        selectedTaskId = nil
        self.userProfile = UserProfileService.loadProfileFromLocal(userId: userId)
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
                self?.tasks = taskList.map { TaskModel(entity: $0) }
                self?.filterTasks()
            })
            .store(in: &cancellables)
    }
    func filterTasks() {
        let query = searchQuery.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = query.isEmpty
        ? tasks
        : tasks.filter {
            $0.title.lowercased().contains(query) ||
            $0.descriptionText.lowercased().contains(query)
        }
        filteredTasks = filtered.sorted {
            if $0.isPriority != $1.isPriority {
                return $0.isPriority && !$1.isPriority
            }
            return $0.createdAt > $1.createdAt
        }
    }
    func onAddTaskTapped() {
        router.navigateToAddTask(userId: userId, onTasksUpdated: { [weak self] in
            self?.loadTasks()
        })
    }
    func onEditTaskTapped(_ task: TaskModel) {
        router.navigateToEditTask(task: task.toEntity(), onTasksUpdated: { [weak self] in
            self?.loadTasks()
        })
    }
    
    func onDeleteTaskByOffsets(_ offsets: IndexSet) {
        let index = offsets.first!
        let task = filteredTasks[index]
        pendingDeleteTaskId = task.id
        
        tasks.removeAll { $0.id == task.id }
        filterTasks()
        showDeleteConfirmation = true
    }
    
    func onDeleteTaskTapped(_ id: UUID) {
        showDeleteConfirmation = true
        taskToDelete = id
    }
    func confirmDeleteTask() {
        guard let id = pendingDeleteTaskId else { return }
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
    
    func cancelDeleteTask() {
        if let id = pendingDeleteTaskId {
            loadTasks()
        }
        pendingDeleteTaskId = nil
        showDeleteConfirmation = false
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
    func onTaskSelected(_ task: TaskModel) {
        selectedTaskId = task.id
        onEditTaskTapped(task)
    }
    func onDismissErrorTapped() {
        errorMessage = nil
    }
}
