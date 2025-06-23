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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Type Task Title", text: Binding(
                    get: { presenter.task.title },
                    set: { presenter.onTitleChanged($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit { focusedField = .notes }

                Toggle("Priority Task", isOn: Binding(
                    get: { presenter.task.isPriority },
                    set: { presenter.onPriorityChanged($0) }
                )).toggleStyle(SwitchToggleStyle(tint: .red))

                Toggle("Set Due Date", isOn: Binding(
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
                        DatePicker("Select Due Date", selection: Binding(
                            get: { presenter.task.dueDate ?? Date() },
                            set: { presenter.onDueDateChanged($0) }
                        ), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                }

                Toggle("Enable Reminder", isOn: Binding(
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
                        DatePicker("Reminder Time", selection: Binding(
                            get: { presenter.task.reminderDate ?? Date() },
                            set: { presenter.onReminderChanged(true, date: $0) }
                        ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding()
                    }
                }

                Picker("Status", selection: Binding(
                    get: { presenter.task.status },
                    set: { presenter.onStatusChanged($0) }
                )) {
                    ForEach(TaskStatus.allCases, id: \.self) {
                        Text($0.rawValue.capitalized).tag($0)
                    }
                }.pickerStyle(SegmentedPickerStyle())

                // Photo section
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

                // Note section
                TextEditor(text: Binding(
                    get: { presenter.task.descriptionText },
                    set: { presenter.onDescChanged($0) }
                ))
                .focused($focusedField, equals: .notes)
                .frame(height: 120)
                .cornerRadius(8)
                .padding(.top, 10)

                Button(presenter.mode == .create ? "Add Task" : "Save Task") {
                    presenter.saveTask()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!presenter.isTaskChanged)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle(presenter.mode == .create ? "Add Task" : "Edit Task")
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
}
