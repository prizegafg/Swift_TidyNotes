//
//  TaskListInteractor.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

class TaskListInteractor: TaskListInteractorProtocol {

    private let taskRepository: TaskRepositoryProtocol
    private var presenter: TaskListPresenterProtocol?

    private var cancellables = Set<AnyCancellable>()

    init(taskRepository: TaskRepositoryProtocol,
         presenter: TaskListPresenterProtocol?) {
        self.taskRepository = taskRepository
        self.presenter = presenter
    }
    
    func setPresenter(_ presenter: TaskListPresenterProtocol) {
        self.presenter = presenter
    }

    func fetchTasks(for projectId: UUID?) {
        taskRepository
            .getTasks(projectId: projectId)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.presenter?.presentError(error.localizedDescription)
                }
            }, receiveValue: { tasks in
                self.presenter?.presentTasks(tasks)
            })
            .store(in: &cancellables)
    }

    func toggleTaskCompletion(_ task: Task) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.updatedAt = Date()

        taskRepository
            .updateTask(updatedTask)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                self.fetchTasks(for: task.projectId)
            })
            .store(in: &cancellables)
    }

    func deleteTask(_ task: Task) {
        taskRepository
            .deleteTask(task)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                self.fetchTasks(for: task.projectId)
            })
            .store(in: &cancellables)
    }

    func addTask(title: String, to projectId: UUID?) {
        let newTask = Task(
            id: UUID(),
            title: title,
            isCompleted: false,
            projectId: projectId,
            createdAt: Date(),
            updatedAt: Date()
        )

        taskRepository
            .addTask(newTask)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                self.fetchTasks(for: projectId)
            })
            .store(in: &cancellables)
    }
}


