//
//  TaskDetailView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import SwiftUI
import Combine
import PhotosUI

struct TaskDetailView: View {
    @ObservedObject var presenter: TaskDetailPresenter
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: FocusField?
    
    @State private var showDueDatePicker = false
    @State private var showReminderDatePicker = false
    @State private var selectedItem: PhotosPickerItem?
    
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
                photoSection
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
//                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Spacer()
                    Button(action: {
                        showDueDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
                .sheet(isPresented: $showDueDatePicker) {
                    DueDatePickerView(
                        selectedDate: $presenter.dueDate,
                        isPresented: $showDueDatePicker,
                        onDateChanged: { newDate in
                            presenter.dueDateChanged(newDate)
                        }
                    )
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
                    
                    // Inisialisasi reminderDate jika belum ada dan reminder diaktifkan
                    if newValue && presenter.reminderDate == nil {
                        let defaultDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
                        presenter.reminderDateChanged(defaultDate)
                    }
                }
            
            if presenter.isReminderOn {
                HStack {
                    Text(presenter.reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "Select Date")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
//                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Button {
                        showReminderDatePicker.toggle()
                    } label: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.blue)
                    }
                }
                .sheet(isPresented: $showReminderDatePicker) {
                    ReminderDatePickerView(
                        selectedDate: Binding(
                            get: { presenter.reminderDate ?? Date() },
                            set: { presenter.reminderDateChanged($0) }
                        ),
                        isPresented: $showReminderDatePicker
                    )
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
    
    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Photo")
                .font(.headline)

            if let image = presenter.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            } else if let path = presenter.imagePath,
                      let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            }

            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Upload Gambar", systemImage: "photo")
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        presenter.setImage(image)
                    }
                }
            }
        }
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
