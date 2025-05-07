//
//  TaskListView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI
import Combine

struct TaskListView: View {
    @ObservedObject var presenter: TaskListPresenter
    
    var body: some View {
        ZStack {
            VStack {
                if presenter.tasks.isEmpty && !presenter.isLoading {
                    emptyStateView
                } else {
                    taskListView
                }
            }
            
            if presenter.isLoading {
                loadingView
            }
            
            if presenter.errorMessage != nil {
                errorView
            }
            
            floatingActionButton
        }
        .navigationTitle("Tasks")
        .onAppear {
            presenter.viewDidAppear()
            presenter.selectedTaskId = nil
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
        .confirmationDialog(
            "Konfirmasi Hapus",
            isPresented: $presenter.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Ya", role: .destructive) {
                presenter.confirmDeleteTask()
            }
            Button("Tidak", role: .cancel) {}
        } message: {
            Text("Apakah Anda yakin akan menghapus task ini?")
        }
    }
    
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    presenter.onAddTaskTapped()
                }) {
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
    
    private var taskListView: some View {
        List {
            ForEach(presenter.tasks) { task in
                TaskRowView(
                    task: task,
                    isSelected: task.id == presenter.selectedTaskId,
                    onSelect: { presenter.onTaskSelected(task) }
                )
                // Gunakan swipeActions baru daripada onDelete untuk performa yang lebih baik
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        presenter.onDeleteTaskTapped(task.id)
                    } label: {
                        Label("Hapus", systemImage: "trash")
                    }
                    .tint(.red)
                    
                    Button {
                        presenter.onTaskSelected(task)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.blue)
                    
                    
                    
                    if !task.isPriority {
                        Button {
                            presenter.onSetAsPriorityTapped(task)
                        } label: {
                            Label("Priority", systemImage: "star")
                        }
                        .tint(.yellow)
                    }
                }
                .contextMenu {
                    if !task.isPriority {
                        Button(action: {
                            presenter.onSetAsPriorityTapped(task)
                        }) {
                            Label("Set as Priority", systemImage: "star")
                        }
                    }
                    Button(action: {
                        presenter.onEditTaskTapped(task)
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    if !task.isPriority {
                        Button(role: .destructive, action: {
                            presenter.onDeleteTaskTapped(task.id)
                        }) {
                            Label("Hapus", systemImage: "trash")
                        }
                    }
                }
            }
            // Hapus onDelete handler (diganti dengan swipeActions di atas)
        }
        // Tambahkan .listStyle untuk performa yang lebih baik
        .listStyle(PlainListStyle())
    }
    
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
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                ProgressView().scaleEffect(1.5)
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
    
    private var errorView: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.white)
                
                Text(presenter.errorMessage ?? "An error occurred")
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    presenter.onDismissErrorTapped()
                }) {
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
            .animation(.easeInOut, value: presenter.errorMessage)
        }
    }
}

struct TaskRowView: View {
    let task: TaskEntity
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var isDueDateApproaching: Bool {
        guard let dueDate = task.dueDate else { return false }
        return Date().distance(to: dueDate) < 86400
    }
    
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
        return Date().distance(to: date) < 86400
    }
}
