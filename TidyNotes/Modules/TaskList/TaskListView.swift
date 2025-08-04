//
//  TaskListView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI
import Combine

import SwiftUI

struct TaskListView: View {
    @ObservedObject var presenter: TaskListPresenter
    @ObservedObject var navigationState: TaskNavigationState

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    GreetingSection(username: presenter.userProfile?.username)
                    SearchSection(searchQuery: $presenter.searchQuery)

                    if presenter.isLoading {
                        LoadingSection()
                    } else if presenter.tasks.isEmpty && presenter.searchQuery.isEmpty {
                        EmptyTaskSection()
                    } else if presenter.filteredTasks.isEmpty {
                        NoSearchDataSection()
                    } else {
                        TaskListSection(
                            tasks: presenter.filteredTasks,
                            selectedTaskId: presenter.selectedTaskId,
                            onSelect: presenter.onTaskSelected,
                            onDelete: presenter.onDeleteTaskByOffsets
                        )
                    }
                }
                ErrorBannerSection(
                    errorMessage: presenter.errorMessage,
                    onDismiss: presenter.onDismissErrorTapped
                )
                FloatingActionButtonSection {
                    presenter.onAddTaskTapped()
                }
            }
            .navigationTitle("Tasks".localizedDescription)
            .onAppear {
                presenter.viewDidAppear()
                presenter.selectedTaskId = nil
            }
            .confirmationDialog(
                "Are you sure you want to delete this task?",
                isPresented: $presenter.showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    presenter.confirmDeleteTask()
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert(isPresented: .constant(presenter.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(presenter.errorMessage ?? ""),
                    dismissButton: .default(Text("OK")) {
                        presenter.onDismissErrorTapped()
                    }
                )
            }
            
            .navigationDestination(
                isPresented: $navigationState.showTaskDetail,
                destination: {
                    if let taskId = presenter.selectedTaskId {
                        TaskDetailRouter.makeTaskDetailView(taskId: taskId)
                    }
                }
            )
            
            .navigationBarItems(
                trailing: NavigationLink(
                    destination: SettingsModule.makeSettingsView()
                ) {
                    Image(systemName: "gear")
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
        }
        
    }
}


private struct GreetingSection: View {
    let username: String?
    var body: some View {
        if let username {
            HStack {
                Text("Hello, \(username)!")
                    .font(.headline)
                Spacer()
            }
            .padding(.leading)
        }
    }
}

private struct SearchSection: View {
    @Binding var searchQuery: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search task...".localizedDescription, text: $searchQuery)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.top)
    }
}

private struct TaskRowView: View {
    let task: TaskModel
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: { onSelect() }) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .accentColor : .primary)
                    if !task.descriptionText.isEmpty {
                        Text(task.descriptionText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    if let due = task.dueDate {
                        Text("Due: \(due.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                HStack(spacing: 4) {
                    ProgressBadge(status: task.status)
                    if task.isPriority {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    
                }
//                if isSelected {
//                    Image(systemName: "chevron.right")
//                        .foregroundColor(.accentColor)
//                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TaskListSection: View {
    let tasks: [TaskModel]
    let selectedTaskId: UUID?
    let onSelect: (TaskModel) -> Void
    let onDelete: (IndexSet) -> Void

    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRowView(
                    task: task,
                    isSelected: task.id == selectedTaskId,
                    onSelect: { onSelect(task) }
                )
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
    }
}

private struct EmptyTaskSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("No Task Found".localizedDescription)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text("Please Create New Task using + Button".localizedDescription)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct NoSearchDataSection: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No tasks found".localizedDescription)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text("Try search with other keyword or create a task".localizedDescription)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct LoadingSection: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                ProgressView().scaleEffect(1.5)
                Text("Loading Tasks...".localizedDescription)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.7))
            )
        }
        .transition(.opacity)
    }
}

private struct ErrorBannerSection: View {
    let errorMessage: String?
    let onDismiss: () -> Void
    var body: some View {
        if let errorMessage {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.white)
                    Text(errorMessage)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.red)
                .cornerRadius(8)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: errorMessage)
            }
        }
    }
}

private struct FloatingActionButtonSection: View {
    let onTap: () -> Void
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: onTap) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

private struct ProgressBadge: View {
    let status: TaskStatus
    var body: some View {
        Text(statusDisplay)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(statusColor)
            .cornerRadius(6)
            .padding(.leading, 4)
    }
    var statusDisplay: String {
        switch status {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        }
    }
    var statusColor: Color {
        switch status {
        case .todo: return .gray
        case .inProgress: return .blue
        case .done: return .green
        }
    }
}

