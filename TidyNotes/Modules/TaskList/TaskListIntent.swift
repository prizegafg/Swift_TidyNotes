//
//  TaskListIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

//import Foundation
//import Combine
import Combine
import Foundation

class TaskListPresenter: ObservableObject {
    // Published properties untuk View
    @Published var tasks: [TaskEntity] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var selectedTaskId: UUID? = nil
    
    // Dependencies
    private let interactor: TaskListInteractorProtocol
    private let router: TaskListRouterProtocol
    
    init(interactor: TaskListInteractorProtocol, router: TaskListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }
    
    // MARK: - View Event Methods
    
    func viewDidAppear() {
        fetchTasks()
    }
    
    func onTaskSelected(_ task: TaskEntity) {
        selectedTaskId = task.id
    }
    
    func onAddTaskTapped() {
        router.navigateToAddTask()
    }
    
    func onEditTaskTapped(_ task: TaskEntity) {
        router.navigateToEditTask(task)
    }
    
    func onDeleteTaskTapped(_ taskId: UUID) {
        isLoading = true
        error = nil
        
        interactor.deleteTask(id: taskId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.fetchTasks()
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func onSetAsPriorityTapped(_ task: TaskEntity) {
        isLoading = true
        error = nil
        
        interactor.setTaskAsPriority(id: task.id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    self?.fetchTasks()
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func onDismissErrorTapped() {
        error = nil
    }
    
    // MARK: - Private Methods
    
    private func fetchTasks() {
        isLoading = true
        error = nil
        
        interactor.fetchAllTasks { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let tasks):
                    self?.tasks = tasks.sorted { $0.createdAt > $1.createdAt }
                    // Jika ada priority task, select itu
                    if let priorityTask = tasks.first(where: { $0.isPriority }) {
                        self?.selectedTaskId = priorityTask.id
                    }
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
