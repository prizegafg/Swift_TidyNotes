//
//  TaskListContainerView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import SwiftUI

struct TaskListContainerView: View {
    @ObservedObject var presenter: TaskListPresenter
    @ObservedObject var navigationState: TaskNavigationState
    
    var body: some View {
        NavigationStack {
            TaskListView(presenter: presenter)
                .navigationDestination(
                    isPresented: $navigationState.showTaskDetail,
                    destination: {
                        if let taskId = presenter.selectedTaskId {
                            TaskDetailRouter.makeTaskDetailView(taskId: taskId)
                        }
                    }
                )
                .sheet(isPresented: $navigationState.showAddTask) {
                    TaskDetailRouter.makeAddTaskView(
                        userId: presenter.userId,
                        onTasksUpdated: {
                            presenter.viewDidAppear()
                        }
                    )
                }
                .sheet(isPresented: $navigationState.showEditTask) {
                    if let task = navigationState.selectedTaskForEdit {
                        TaskDetailRouter.makeTaskDetailView(taskId: task.id)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        presenter.selectedTaskId = nil
                    }
                }
        }
        .withAppTheme()
        .task {
            if let deepLink = DeepLinkManager.shared.consume() {
                switch deepLink {
                case .openTaskDetail(let taskId):
                    presenter.selectedTaskId = taskId
                    navigationState.showTaskDetail = true
                }
            }
        }
    }
}
