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
                    TaskDetailRouter.makeAddTaskView(onTasksUpdated: {
                        presenter.viewDidAppear()
                    })
                }
                .sheet(isPresented: $navigationState.showEditTask) {
                    if let task = navigationState.selectedTaskForEdit {
                        TaskAddEditModule.makeEditTaskView(task: task)
                    }
                }
                .onAppear {
                    DispatchQueue.main.async {
                        presenter.selectedTaskId = nil
                    }
                }
        }
    }
}
