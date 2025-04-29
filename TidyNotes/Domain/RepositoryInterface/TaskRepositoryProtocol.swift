//
//  TaskRepositoryProtocol.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

protocol TaskRepositoryProtocol {
    func getTasks(projectId: UUID?) -> AnyPublisher<[Task], Error>
    func addTask(_ task: Task) -> AnyPublisher<Void, Error>
    func updateTask(_ task: Task) -> AnyPublisher<Void, Error>
    func deleteTask(_ task: Task) -> AnyPublisher<Void, Error>
}
