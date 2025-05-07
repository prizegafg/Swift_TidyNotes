//
//  TaskDetailView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import SwiftUI
import Combine

struct TaskDetailView: View {
    @ObservedObject var presenter: TaskDetailPresenter
    @State private var showDatePicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                titleSection
                dueDateSection
                prioritySection
                statusSection
                noteSection
            }
            .padding()
        }
        .navigationTitle(presenter.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Batal") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(presenter.saveButtonTitle) {
                    presenter.saveTask()
                }
                .disabled(!presenter.isTaskChanged)
            }
        }
        .onAppear {
            presenter.viewDidLoad()
        }
        .alert(isPresented: $presenter.showError) {
            Alert(
                title: Text("Error"),
                message: Text(presenter.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .overlay(
            ZStack {
                if presenter.isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        )
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Judul")
                .font(.headline)
            
            TextField("Masukkan judul tugas", text: $presenter.taskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 4)
                .onChange(of: presenter.taskTitle) { newValue in
                    presenter.titleChanged(newValue)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tenggat Waktu")
                .font(.headline)
            
            Toggle("Tetapkan tenggat waktu", isOn: $presenter.hasDueDate)
                .onChange(of: presenter.hasDueDate) { newValue in
                    presenter.hasDueDateChanged(newValue)
                }
            
            if presenter.hasDueDate {
                HStack {
                    Text(presenter.formattedDueDate)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
                
                if showDatePicker {
                    DatePicker("", selection: $presenter.dueDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onChange(of: presenter.dueDate) { newValue in
                            presenter.dueDateChanged(newValue)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prioritas")
                .font(.headline)
            
            Toggle("Tugas prioritas", isOn: $presenter.isPriority)
                .onChange(of: presenter.isPriority) { newValue in
                    presenter.priorityChanged(newValue)
                }
                .toggleStyle(SwitchToggleStyle(tint: .red))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)
            
            Picker("Status", selection: $presenter.taskStatus) {
                ForEach(presenter.statusOptions, id: \.self) { status in
                    Text(status.rawValue).tag(status)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: presenter.taskStatus) { newValue in
                presenter.statusChanged(newValue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Catatan")
                    .font(.headline)
                
                Spacer()
                
                // Hanya tampilkan status "terakhir diperbarui" pada mode edit
                if presenter.mode == .edit {
                    Text("Terakhir diperbarui: \(presenter.lastUpdatedFormatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            TextEditor(text: $presenter.noteContent)
                .onChange(of: presenter.noteContent) { newValue in
                    presenter.noteContentChanged(newValue)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, minHeight: 150)
        }
    }
}
