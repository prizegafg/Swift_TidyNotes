//
//  TaskListView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import SwiftUI
import Combine

struct TaskListView: View {
    @StateObject var intent: TaskListIntent
    let projectId: UUID?
    var body: some View {
        NavigationView {
            List {
                ForEach(intent.tasks) { task in
                    HStack {
                        Button(action: {
                            intent.toggleCompletion(task)
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }
                        Text(task.title)
                            .strikethrough(task.isCompleted)
                            .foregroundColor(task.isCompleted ? .gray : .primary)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { idx in
                        intent.delete(intent.tasks[idx])
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        intent.addTask(title: "New Task", projectId: projectId)
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .onAppear {
            intent.onAppear(projectId: projectId)
        }
//        .alert(item: Binding.constant(intent.errorMessage)) { msg in
//            Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
//        }
        .alert(item: $intent.errorMessage) { error in
            Alert(title: Text("Error"),
                  message: Text(error.message),
                  dismissButton: .default(Text("OK")))
        }
    }
}
