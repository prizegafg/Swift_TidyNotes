//
//  TaskListView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI
import Combine

/// View utama untuk menampilkan daftar task
struct TaskListView: View {
    @ObservedObject private var intent: TaskListIntent
    
    init(intent: TaskListIntent) {
        self.intent = intent
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content
                VStack {
                    if intent.state.tasks.isEmpty && !intent.state.isLoading {
                        emptyStateView
                    } else {
                        taskListView
                    }
                }
                
                // Loading indicator
                if intent.state.isLoading {
                    loadingView
                }
                
                // Error toast (if there's an error)
                if intent.state.error != nil {
                    errorView
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { intent.navigateToAddTask() }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All", action: { intent.setFilter(.all) })
                        Button("Active", action: { intent.setFilter(.active) })
                        Button("Completed", action: { intent.setFilter(.completed) })
                        Button("Due Today", action: { intent.setFilter(.dueToday) })
                        Button("Overdue", action: { intent.setFilter(.overdue) })
                        
                        Menu("By Tag") {
                            ForEach(TaskTag.allCases) { tag in
                                Button(tag.displayName) {
                                    intent.setFilter(.byTag(tag))
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .onAppear {
                intent.fetchTasks()
            }
        }
    }
    
    /// View untuk daftar task
    private var taskListView: some View {
        List {
            ForEach(intent.state.tasks) { task in
                TaskRowView(
                    task: task,
                    onToggleCompletion: { intent.toggleTaskCompletion(task: task) },
                    onTap: { intent.navigateToTaskDetail(task: task) }
                )
                .contextMenu {
                    Button(action: { intent.toggleTaskCompletion(task: task) }) {
                        Label(
                            task.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                            systemImage: task.isCompleted ? "circle" : "checkmark.circle"
                        )
                    }
                    
                    Button(role: .destructive, action: { intent.deleteTask(id: task.id) }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let task = intent.state.tasks[index]
                    intent.deleteTask(id: task.id)
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
                intent.navigateToAddTask()
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
                
                Text(intent.state.error?.localizedDescription ?? "An error occurred")
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { intent.resetError() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.red)
            .cornerRadius(8)
            .padding()
        }
        .transition(.move(edge: .bottom))
        .animation(.easeInOut, value: intent.state.error != nil)
    }
}

/// View untuk menampilkan row task
struct TaskRowView: View {
    let task: TaskEntity
    let onToggleCompletion: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Button(action: onToggleCompletion) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(task.isCompleted ? .green : .gray)
                        .font(.system(size: 20))
                }
                .buttonStyle(BorderlessButtonStyle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                    
                    if let dueDate = task.dueDate {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.caption)
                            
                            Text(formatDate(dueDate))
                                .font(.caption)
                                .foregroundColor(isOverdue(dueDate) && !task.isCompleted ? .red : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                if let tag = task.tag {
                    Text(tag.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(tagColor(for: tag))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Format tanggal untuk tampilan
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // Cek apakah task overdue
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date()
    }
    
    // Mendapatkan warna berdasarkan tag
    private func tagColor(for tag: TaskTag) -> Color {
        switch tag {
        case .work: return .blue
        case .personal: return .green
        case .shopping: return .orange
        case .health: return .red
        case .finance: return .purple
        case .other: return .gray
        }
    }
}

#Preview {
    TaskListRouter.makeTaskListView()
}
