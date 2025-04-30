//
//  TaskRepository.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 30/04/25.
//

import Foundation
import Combine

/// Protocol untuk repository task
protocol TaskRepository {
    /// Mengambil daftar task
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError>
    
    /// Menambah task baru
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    
    /// Mengupdate task yang sudah ada
    func updateTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError>
    
    /// Menghapus task berdasarkan ID
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError>
}

/// Implementasi dummy dari TaskRepository yang menyimpan data di memory
final class InMemoryTaskRepository: TaskRepository {
    /// Shared instance untuk singleton pattern
    static let shared = InMemoryTaskRepository()
    
    /// Storage untuk menyimpan tasks
    private var tasks: [TaskEntity]
    
    private init() {
        // Inisialisasi dengan beberapa dummy task
        let calendar = Calendar.current
        let today = Date()
        
        tasks = [
            TaskEntity(
                title: "Menyelesaikan proposal project",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 1, to: today),
                tag: .work
            ),
            TaskEntity(
                title: "Meeting dengan klien",
                isCompleted: true,
                dueDate: calendar.date(byAdding: .day, value: -1, to: today),
                tag: .work
            ),
            TaskEntity(
                title: "Membeli bahan makanan",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 2, to: today),
                tag: .shopping
            ),
            TaskEntity(
                title: "Latihan gym",
                isCompleted: false,
                dueDate: today,
                tag: .health
            ),
            TaskEntity(
                title: "Membayar tagihan listrik",
                isCompleted: false,
                dueDate: calendar.date(byAdding: .day, value: 5, to: today),
                tag: .finance
            )
        ]
    }
    
    func fetchTasks() -> AnyPublisher<[TaskEntity], TaskError> {
        // Simulasi network delay
        return Future<[TaskEntity], TaskError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // Uncomment baris di bawah untuk mensimulasikan error
                // promise(.failure(.fetchFailed))
                promise(.success(self.tasks))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        return Future<TaskEntity, TaskError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                self.tasks.append(task)
                promise(.success(task))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateTask(_ task: TaskEntity) -> AnyPublisher<TaskEntity, TaskError> {
        return Future<TaskEntity, TaskError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if let index = self.tasks.firstIndex(where: { $0.id == task.id }) {
                    self.tasks[index] = task
                    promise(.success(task))
                } else {
                    promise(.failure(.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteTask(id: UUID) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if let index = self.tasks.firstIndex(where: { $0.id == id }) {
                    self.tasks.remove(at: index)
                    promise(.success(()))
                } else {
                    promise(.failure(.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
