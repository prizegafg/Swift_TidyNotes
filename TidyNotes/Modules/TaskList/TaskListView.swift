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
                // SearchBar
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Cari task...", text: $presenter.searchQuery)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.top)
                
                // List or Empty State
                if presenter.isLoading {
                    loadingView
                } else if presenter.filteredTasks.isEmpty {
                    noSearchDataView
                } else {
                    taskListView
                }
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
        .navigationBarItems(
            trailing: NavigationLink(
                destination: SettingsModule.makeSettingsView()
            ) {
                Image(systemName: "gear")
            }
        )
        // ConfirmationDialog & lainnya tetap sesuai kebutuhan
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
            ForEach(presenter.filteredTasks) { task in
                TaskRowView(
                    task: task,
                    isSelected: task.id == presenter.selectedTaskId,
                    onSelect: { presenter.onTaskSelected(task) }
                )
                // swipeActions/contextMenu tetap
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var noSearchDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No tasks found")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text("Coba cari dengan kata lain atau tambah task baru.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 40)
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
    
    private var isDueSoon: Bool {
        guard let dueDate = task.dueDate else { return false }
        return Date().distance(to: dueDate) < 86400
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                
                if !task.descriptionText.isEmpty {
                    Text(task.descriptionText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: DateFormatter.shortDate)")
                        .font(.caption)
                        .foregroundColor(isDueSoon ? .orange : .secondary)
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
        .onTapGesture { onSelect() }
        .padding(.vertical, 4)
    }
}
