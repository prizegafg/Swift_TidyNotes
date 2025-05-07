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

final class TaskListPresenter: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedTaskId: UUID? = nil

    private let interactor: TaskListInteractor
    private let router: TaskListRouter
    private var cancellables = Set<AnyCancellable>()

    init(interactor: TaskListInteractor, router: TaskListRouter) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidAppear() {
        fetchTasks()
    }

    func onTaskSelected(_ task: TaskEntity) {
        selectedTaskId = task.id
        router.navigateToTaskDetail(task.id)
    }

    func onAddTaskTapped() {
        router.navigateToAddTask()
    }

    func onEditTaskTapped(_ task: TaskEntity) {
        router.navigateToEditTask(task)
    }

    func onDeleteTaskTapped(_ taskId: UUID) {
        isLoading = true
        errorMessage = nil

        interactor.deleteTask(id: taskId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: { [weak self] in
                self?.fetchTasks()
            })
            .store(in: &cancellables)
    }

    func onSetAsPriorityTapped(_ task: TaskEntity) {
        isLoading = true
        errorMessage = nil

        interactor.setTaskAsPriority(id: task.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: { [weak self] in
                self?.fetchTasks()
            })
            .store(in: &cancellables)
    }

    func onDismissErrorTapped() {
        errorMessage = nil
    }

    private func fetchTasks() {
        isLoading = true
        errorMessage = nil

        interactor.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: { [weak self] tasks in
//                self?.tasks = tasks.sorted { $0.createdAt > $1.createdAt }
//                self?.selectedTaskId = tasks.first(where: { $0.isPriority })?.id
                self?.tasks = tasks.sorted { $0.createdAt > $1.createdAt }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    private func handleCompletion(_ completion: Subscribers.Completion<Error>) {
        isLoading = false
        if case let .failure(error) = completion {
            errorMessage = error.localizedDescription
        }
    }
}
