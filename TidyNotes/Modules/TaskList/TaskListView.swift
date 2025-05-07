//
//  TaskListView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI
import Combine

struct TaskListView: View {
    @ObservedObject private var presenter: TaskListPresenter
    @Environment(\.presentationMode) var presentationMode
    
    init(presenter: TaskListPresenter) {
        self.presenter = presenter
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack {
                    if presenter.tasks.isEmpty && !presenter.isLoading {
                        emptyStateView
                    } else {
                        taskListView
                    }
                }
                
                // Loading indicator
                if presenter.isLoading {
                    loadingView
                }
                
                // Error toast (if there's an error)
                if $presenter.error != nil {
                    errorView
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presenter.onAddTaskTapped() }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                presenter.viewDidAppear()
            }
        }
    }
    
    /// View untuk daftar task
    private var taskListView: some View {
        List {
            ForEach(presenter.tasks) { task in
                TaskRowView(
                    task: task,
                    isSelected: task.id == presenter.selectedTaskId,
                    onSelect: { presenter.onTaskSelected(task) }
                )
                .contextMenu {
                    if !task.isPriority {
                        Button(action: { presenter.onSetAsPriorityTapped(task) }) {
                            Label("Set as Priority", systemImage: "star")
                        }
                    }
                    
                    Button(action: { presenter.onEditTaskTapped(task) }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    if !task.isPriority {
                        Button(role: .destructive, action: { presenter.onDeleteTaskTapped(task.id) }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let task = presenter.tasks[index]
                    if !task.isPriority {
                        presenter.onDeleteTaskTapped(task.id)
                    }
                }
            }
        }
    }
    
    /// View untuk menampilkan empty state
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Tasks Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add your first task by tapping the + button.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Add Task") {
                presenter.onAddTaskTapped()
            }
            .padding(.top, 8)
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    /// View untuk menampilkan loading state
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("Loading Tasks...")
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
    
    /// View untuk menampilkan error
    private var errorView: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.white)
                
                Text($presenter.error.localizedDescription ?? "An error occurred")
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { presenter.onDismissErrorTapped() }) {
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
            .animation(.easeInOut, value: $presenter.error != nil)
        }
    }
}

/// View untuk row task dalam list
struct TaskRowView: View {
    let task: TaskEntity
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Display due date if available
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: DateFormatter.shortDate)")
                        .font(.caption)
                        .foregroundColor(isDueDateApproaching(dueDate) ? .orange : .secondary)
                }
            }
            
            Spacer()
            
            if task.isPriority {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .padding(.vertical, 4)
    }
    
    private func isDueDateApproaching(_ date: Date) -> Bool {
        return Date().distance(to: date) < 86400 // Less than 24 hours
    }
}
