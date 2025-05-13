//
//  TaskRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 09/05/25.
//

import Foundation
import Combine


// MARK: - Task Repository Protocol
protocol TaskRepositoryProtocol {
    func fetchAllTasks() -> AnyPublisher<[TaskEntity], Never>
    func fetchTask(by id: UUID) -> AnyPublisher<TaskEntity?, Never>
    func saveTask(_ task: TaskEntity)
    func deleteTask(_ task: TaskEntity)
    func deleteAllTasks()
}


// MARK: - Task Repository
final class TaskRepository: TaskRepositoryProtocol {

    private let realmManager: RealmManager

    init(realmManager: RealmManager = .shared) {
        self.realmManager = realmManager
    }

    // MARK: - Fetch

    func fetchAllTasks() -> AnyPublisher<[TaskEntity], Never> {
        let tasks = realmManager.fetchAllTasks()
        return Just(tasks)
            .eraseToAnyPublisher()
    }

    func fetchTask(by id: UUID) -> AnyPublisher<TaskEntity?, Never> {
        let task = realmManager.fetchTask(by: id)
        return Just(task)
            .eraseToAnyPublisher()
    }

    // MARK: - Create / Update

    func saveTask(_ task: TaskEntity) {
        realmManager.addOrUpdateTask(task)
    }

    // MARK: - Delete

    func deleteTask(_ task: TaskEntity) {
        realmManager.deleteTask(task)
    }

    func deleteAllTasks() {
        realmManager.deleteAllTasks()
    }
}
