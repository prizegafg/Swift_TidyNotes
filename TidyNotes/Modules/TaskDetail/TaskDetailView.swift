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
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: FocusField?
    @State private var showDatePicker = false
    
    enum FocusField {
        case title, notes
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                titleSection
                dueDateSection
                reminderSection
                prioritySection
                statusSection
                noteSection
            }
            .padding()
        }
        .navigationTitle(presenter.navigationTitle)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(presenter.saveButtonTitle) {
                    presenter.saveTask()
                    presentationMode.wrappedValue.dismiss()
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
        // Dismiss keyboard when tapping outside textfields
        .onTapGesture {
            focusedField = nil
        }
        // Custom modifier to fix router dismiss behavior
        .onDisappear {
            // Ensure router has a chance to clean up properly
            presenter.dismiss()
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)
            
            TextField("Type Task Title", text: $presenter.taskTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 4)
                .onChange(of: presenter.taskTitle) { newValue in
                    presenter.titleChanged(newValue)
                }
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .notes
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Due Date")
                .font(.headline)
            Toggle("Set Due Date", isOn: $presenter.hasDueDate)
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
                        presenter.toggleDatePicker()
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
                
                if presenter.showDatePicker {
                    VStack {
                        DatePicker("", selection: $presenter.dueDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .onChange(of: presenter.dueDate) { newValue in
                                presenter.dueDateChanged(newValue)
                            }
                        
                        // Add Done button for date picker
                        HStack {
                            Spacer()
                            Button("Done") {
                                presenter.toggleDatePicker()
                            }
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reminder")
                .font(.headline)

            Toggle("Enable Reminder", isOn: $presenter.isReminderOn)
                .onChange(of: presenter.isReminderOn) { newValue in
                    presenter.reminderToggleChanged(newValue)
                }

            if presenter.isReminderOn {
                HStack {
                    Text(presenter.reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "Select Date")
                        .foregroundColor(.gray)
                    Spacer()
                    Button {
                        presenter.toggleDatePicker()
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                    }
                }

                if presenter.showDatePicker {
                    VStack {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { presenter.reminderDate ?? Date() },
                                set: { presenter.reminderDateChanged($0) }
                            ),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)

                        HStack {
                            Spacer()
                            Button("Done") {
                                presenter.toggleDatePicker()
                            }
                            .padding(8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    }

    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Priority")
                .font(.headline)
            Toggle("Priority Task", isOn: $presenter.isPriority)
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
                Text("Notes")
                    .font(.headline)
                
                Spacer()
                
                if presenter.mode == .edit {
                    Text("Last Update: \(presenter.lastUpdatedFormatted)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ZStack {
                if presenter.noteContent.isEmpty {
                    Text("Enter your notes here...")
                        .foregroundColor(Color(.placeholderText))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                TextEditor(text: $presenter.noteContent)
                    .focused($focusedField, equals: .notes)
                    .onChange(of: presenter.noteContent) { newValue in
                        presenter.noteContentChanged(newValue)
                    }
                    .padding(8)
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(10)
            }
        }
    }
}
