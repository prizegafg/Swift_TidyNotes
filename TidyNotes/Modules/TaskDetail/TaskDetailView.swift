//
//  TaskDetailView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import SwiftUI
import PhotosUI

struct TaskDetailView: View {
    @ObservedObject var presenter: TaskDetailPresenter
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var focusedField: FocusField?

    enum FocusField { case title, notes }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TitleSection(
                    title: presenter.taskModel.title,
                    onTitleChanged: presenter.onTitleChanged,
                    focusedField: $focusedField
                )
                PrioritySection(
                    isPriority: presenter.taskModel.isPriority,
                    onPriorityChanged: presenter.onPriorityChanged
                )
                DueDateSection(
                    dueDate: presenter.taskModel.dueDate,
                    showDueDatePicker: $presenter.showDueDatePicker,
                    onDueDateChanged: presenter.onDueDateChanged
                )
                ReminderSection(
                    isReminderOn: presenter.taskModel.isReminderOn,
                    reminderDate: presenter.taskModel.reminderDate,
                    showReminderDatePicker: $presenter.showReminderDatePicker,
                    onReminderChanged: presenter.onReminderChanged
                )
                StatusSection(
                    status: presenter.taskModel.status,
                    onStatusChanged: presenter.onStatusChanged
                )
                ImageSection(
                    selectedImage: presenter.selectedImage,
                    imagePath: presenter.taskModel.imagePath,
                    onUploadTapped: { presenter.showFeatureInProgress = true }
                )
                DescriptionSection(
                    descriptionText: presenter.taskModel.descriptionText,
                    onDescChanged: presenter.onDescChanged,
                    focusedField: $focusedField
                )
                
                Spacer(minLength: 150)
                VStack {
                    Divider()
                    Button(
                        presenter.mode == .create ? "Add Task".localizedDescription : "Save Task".localizedDescription,
                        action: {
                            presenter.saveTask()
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .disabled(!presenter.isTaskChanged)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .background(
                    Color(.systemBackground)
                        .ignoresSafeArea(edges: .bottom)
                        .opacity(0.95)
                )
            }
            .padding()
        }
        .withAppTheme()
        .navigationTitle(presenter.mode == .create ? "Add Task".localizedDescription : "Edit Task".localizedDescription)
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $presenter.showFeatureInProgress) {
            InProgressDialog {
                presenter.showFeatureInProgress = false
            }
        }
        .overlay(
            Group {
                if presenter.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                    }
                }
            }
        )
        .onAppear {
            if presenter.mode == .edit {
                presenter.viewDidLoad(taskId: presenter.taskModel.id)
            }
        }
        .onTapGesture { focusedField = nil }
    }
}

// MARK: - Section Structs

struct TitleSection: View {
    var title: String
    var onTitleChanged: (String) -> Void
    var focusedField: FocusState<TaskDetailView.FocusField?>.Binding

    var body: some View {
        TextField("Type Task Title".localizedDescription, text: Binding(
            get: { title },
            set: { onTitleChanged($0) }
        ))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .focused(focusedField, equals: TaskDetailView.FocusField.title)
        .submitLabel(.next)
        .onSubmit { focusedField.wrappedValue = TaskDetailView.FocusField.notes }
    }
}

struct PrioritySection: View {
    var isPriority: Bool
    var onPriorityChanged: (Bool) -> Void

    var body: some View {
        Toggle("Priority Task".localizedDescription, isOn: Binding(
            get: { isPriority },
            set: { onPriorityChanged($0) }
        ))
        .toggleStyle(SwitchToggleStyle(tint: .red))
    }
}

struct DueDateSection: View {
    var dueDate: Date?
    @Binding var showDueDatePicker: Bool
    var onDueDateChanged: (Date?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Set Due Date".localizedDescription, isOn: Binding(
                get: { dueDate != nil },
                set: { $0 ? onDueDateChanged(dueDate ?? Date()) : onDueDateChanged(nil) }
            ))
            if dueDate != nil {
                HStack {
                    Text(dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "-")
                    Spacer()
                    Button {
                        showDueDatePicker.toggle()
                    } label: { Image(systemName: "calendar").foregroundColor(.blue) }
                }
                .sheet(isPresented: $showDueDatePicker) {
                    DatePicker(
                        "Select Due Date".localizedDescription,
                        selection: Binding(get: { dueDate ?? Date() }, set: { onDueDateChanged($0) }),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
            }
        }
    }
}

struct ReminderSection: View {
    var isReminderOn: Bool
    var reminderDate: Date?
    @Binding var showReminderDatePicker: Bool
    var onReminderChanged: (Bool, Date?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Enable Reminder".localizedDescription, isOn: Binding(
                get: { isReminderOn },
                set: { onReminderChanged($0, reminderDate) }
            ))
            if isReminderOn {
                HStack {
                    Text(reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "-")
                    Spacer()
                    Button { showReminderDatePicker.toggle() } label: {
                        Image(systemName: "calendar.badge.clock").foregroundColor(.blue)
                    }
                }
                .sheet(isPresented: $showReminderDatePicker) {
                    DatePicker(
                        "Reminder Time".localizedDescription,
                        selection: Binding(get: { reminderDate ?? Date() }, set: { onReminderChanged(true, $0) }),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
            }
        }
    }
}

struct StatusSection: View {
    var status: TaskStatus
    var onStatusChanged: (TaskStatus) -> Void

    var body: some View {
        Picker("Status".localizedDescription, selection: Binding(
            get: { status },
            set: { onStatusChanged($0) }
        )) {
            ForEach(TaskStatus.allCases, id: \.self) {
                Text($0.rawValue.capitalized).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct ImageSection: View {
    var selectedImage: UIImage?
    var imagePath: String?
    var onUploadTapped: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            } else if let path = imagePath,
                      let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            Button(action: onUploadTapped) {
                Label("Upload Picture".localizedDescription, systemImage: "photo")
            }
        }
    }
}

struct DescriptionSection: View {
    var descriptionText: String
    var onDescChanged: (String) -> Void
    var focusedField: FocusState<TaskDetailView.FocusField?>.Binding

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: Binding(
                get: { descriptionText },
                set: { onDescChanged($0) }
            ))
            .focused(focusedField, equals: TaskDetailView.FocusField.notes)
            .frame(height: 120)
            .cornerRadius(8)
            .padding(.top, 0)
            
            if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("Type your description here...")
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
                    .padding(.leading, 9)
                    .font(.body)
                    .allowsHitTesting(false)
            }
        }
    }
}

struct SaveButtonSection: View {
    var isEnabled: Bool
    var isCreateMode: Bool
    var onSave: () -> Void

    var body: some View {
        Button(isCreateMode ? "Add Task".localizedDescription : "Save Task".localizedDescription, action: onSave)
            .disabled(!isEnabled)
            .buttonStyle(.borderedProminent)
    }
}
