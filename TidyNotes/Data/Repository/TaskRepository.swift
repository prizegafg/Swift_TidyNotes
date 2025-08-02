//
//  TaskRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 09/05/25.
//

import Foundation
import Combine
import RealmSwift

protocol TaskRepositoryProtocol {
    func fetchTasks(userId: String) -> AnyPublisher<[TaskEntity], Error>
    func fetchTask(by id: UUID) -> AnyPublisher<TaskEntity?, Error>
    func saveTask(_ task: TaskEntity) -> AnyPublisher<Void, Error>
    func deleteTask(_ id: UUID) -> AnyPublisher<Void, Error>
    func disableReminder(for id: String) -> AnyPublisher<Void, Error>
}

final class TaskRepository: TaskRepositoryProtocol {
    private let realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    func fetchTasks(userId: String) -> AnyPublisher<[TaskEntity], Error> {
        let results = realm.objects(TaskEntity.self).where { $0.userId == userId }
        return Just(Array(results))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchTask(by id: UUID) -> AnyPublisher<TaskEntity?, Error> {
        let task = realm.object(ofType: TaskEntity.self, forPrimaryKey: id)
        return Just(task)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func saveTask(_ task: TaskEntity) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.realm.write {
                    self.realm.add(task, update: .modified)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteTask(_ id: UUID) -> AnyPublisher<Void, Error> {
        return Future { promise in
            guard let task = self.realm.object(ofType: TaskEntity.self, forPrimaryKey: id) else {
                TaskService.shared.deleteTaskInFirestore(taskId: id) { _ in
                    promise(.success(()))
                }
                return
            }
            do {
                try self.realm.write {
                    self.realm.delete(task)
                }
                TaskService.shared.deleteTaskInFirestore(taskId: id) { _ in
                    promise(.success(()))
                }
            } catch {
                promise(.failure(error))
            }
            
        }
        .eraseToAnyPublisher()
    }
    
    func disableReminder(for id: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            guard let uuid = UUID(uuidString: id) else {
                promise(.failure(AppError.invalidUUID))
                return
            }
            do {
                if let task = self.realm.object(ofType: TaskEntity.self, forPrimaryKey: uuid) {
                    try self.realm.write {
                        task.isReminderOn = false
                        task.reminderDate = nil
                    }
                    promise(.success(()))
                } else {
                    promise(.failure(AppError.notFound))
                }
            } catch {
                promise(.failure(AppError.realmError(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }
}
