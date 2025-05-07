//
//  TaskListRouter.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import SwiftUI
import Combine

/// Protocol Router untuk Task dalam arsitektur VIPER
final class TaskListRouter {
    private weak var navigationController: UINavigationController?
    private var navigationState: TaskNavigationState?

    init(navigationController: UINavigationController? = nil, navigationState: TaskNavigationState? = nil) {
        self.navigationController = navigationController
        self.navigationState = navigationState
    }

    func navigateToAddTask() {
        navigationState?.showAddTask = true
    }

    func navigateToEditTask(_ task: TaskEntity) {
        navigationState?.selectedTaskForEdit = task
        navigationState?.showEditTask = true
    }
    
    func navigateToTaskDetail(_ taskId: UUID) {
        navigationState?.showTaskDetail = true
    }
}


/// State untuk navigasi SwiftUI
class TaskNavigationState: ObservableObject {
    @Published var showAddTask: Bool = false
    @Published var showEditTask: Bool = false
    @Published var showTaskDetail: Bool = false
    @Published var selectedTaskForEdit: TaskEntity?
}
