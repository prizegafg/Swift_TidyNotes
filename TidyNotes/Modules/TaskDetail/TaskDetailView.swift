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
    @State private var showDueDatePicker = false
    @State private var showReminderDatePicker = false
    @State private var selectedItem: PhotosPickerItem?

    enum FocusField { case title, notes }

    private var titleBinding: Binding<String> {
        Binding(
            get: { presenter.task.title },
            set: { presenter.onTitleChanged($0) }
        )
    }
    private var descBinding: Binding<String> {
        Binding(
            get: { presenter.task.descriptionText },
            set: { presenter.onDescChanged($0) }
        )
    }
    private var dueDateBinding: Binding<Date> {
        Binding(
            get: { presenter.task.dueDate ?? Date() },
            set: { presenter.onDueDateChanged($0) }
        )
    }
    private var reminderDateBinding: Binding<Date> {
        Binding(
            get: { presenter.task.reminderDate ?? Date() },
            set: { presenter.onReminderChanged(true, date: $0) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                titleSection
                prioritySection
                dueDateSection
                reminderSection
                statusSection
                imageSection
                descSection
                saveButtonSection
            }
            .padding()
        }
        .withAppTheme()
        .navigationTitle(presenter.mode == .create ? "Add Task".localizedDescription : "Edit Task".localizedDescription)
        .alert(isPresented: $presenter.showError) {
            Alert(title: Text("Error"), message: Text(presenter.errorMessage), dismissButton: .default(Text("OK")))
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
                presenter.viewDidLoad(taskId: presenter.task.id)
            }
        }
        .onTapGesture { focusedField = nil }
    }

    // MARK: - Subviews

    private var titleSection: some View {
        TextField("Type Task Title".localizedDescription, text: titleBinding)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($focusedField, equals: .title)
            .submitLabel(.next)
            .onSubmit { focusedField = .notes }
    }

    private var prioritySection: some View {
        Toggle("Priority Task".localizedDescription, isOn: Binding(
            get: { presenter.task.isPriority },
            set: { presenter.onPriorityChanged($0) }
        ))
        .toggleStyle(SwitchToggleStyle(tint: .red))
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Set Due Date".localizedDescription, isOn: Binding(
                get: { presenter.task.dueDate != nil },
                set: { $0 ? presenter.onDueDateChanged(presenter.task.dueDate ?? Date()) : presenter.onDueDateChanged(nil) }
            ))
            if presenter.task.dueDate != nil {
                HStack {
                    Text(presenter.task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "-")
                    Spacer()
                    Button {
                        showDueDatePicker.toggle()
                    } label: { Image(systemName: "calendar").foregroundColor(.blue) }
                }
                .sheet(isPresented: $showDueDatePicker) {
                    DatePicker("Select Due Date".localizedDescription, selection: dueDateBinding, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                }
            }
        }
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Enable Reminder".localizedDescription, isOn: Binding(
                get: { presenter.task.isReminderOn },
                set: { presenter.onReminderChanged($0, date: presenter.task.reminderDate) }
            ))
            if presenter.task.isReminderOn {
                HStack {
                    Text(presenter.task.reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "-")
                    Spacer()
                    Button { showReminderDatePicker.toggle() } label: {
                        Image(systemName: "calendar.badge.clock").foregroundColor(.blue)
                    }
                }
                .sheet(isPresented: $showReminderDatePicker) {
                    DatePicker("Reminder Time".localizedDescription, selection: reminderDateBinding, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding()
                }
            }
        }
    }

    private var statusSection: some View {
        Picker("Status".localizedDescription, selection: Binding(
            get: { presenter.task.status },
            set: { presenter.onStatusChanged($0) }
        )) {
            ForEach(TaskStatus.allCases, id: \.self) {
                Text($0.rawValue.capitalized).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var imageSection: some View {
        VStack(spacing: 8) {
            if let image = presenter.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            } else if let path = presenter.task.imagePath,
                      let image = UIImage(contentsOfFile: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Upload Picture".localizedDescription, systemImage: "photo")
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

    private var descSection: some View {
        TextEditor(text: descBinding)
            .focused($focusedField, equals: .notes)
            .frame(height: 120)
            .cornerRadius(8)
            .padding(.top, 10)
    }

    private var saveButtonSection: some View {
        Button(presenter.mode == .create ? "Add Task".localizedDescription : "Save Task".localizedDescription) {
            presenter.saveTask()
            presentationMode.wrappedValue.dismiss()
        }
        .disabled(!presenter.isTaskChanged)
        .buttonStyle(.borderedProminent)
    }
}
