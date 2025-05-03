////
////  SetupTaskView.swift
////  TidyNotes
////
////  Created by Prizega Fromadia on 30/04/25.
////
//
//import SwiftUI
//import Combine
//
///**
// * AddTaskView - Form UI untuk menambahkan task baru
// * - Uses VIPER architecture with TaskListIntent
// * - Combine for reactive validation
// */
//struct AddTaskView: View {
//    // MARK: - Dependencies
//    @ObservedObject var intent: TaskListIntent
//    @Binding var isPresented: Bool
//    
//    // MARK: - Form State
//    @State private var title: String = ""
//    @State private var dueDate: Date? = nil
//    @State private var tag: String = ""
//    @State private var showDatePicker: Bool = false
//    
//    // MARK: - Validation
//    @State private var showValidationAlert: Bool = false
//    @State private var validationMessage: String = ""
//    
//    // MARK: - Combine Cancellables
//    private var cancellables = Set<AnyCancellable>()
//    
//    // MARK: - Init
//    init(intent: TaskListIntent, isPresented: Binding<Bool>) {
//        self._intent = ObservedObject(wrappedValue: intent)
//        self._isPresented = isPresented
//        
//        // Set up response subscribers from intent
//        setupSubscribers()
//    }
//    
//    // MARK: - Body
//    var body: some View {
//        NavigationView {
//            Form {
//                // MARK: Title Field
//                Section(header: Text("Task Details")) {
//                    TextField("Title", text: $title)
//                        .autocapitalization(.sentences)
//                }
//                
//                // MARK: Due Date Field
//                Section(header: Text("Due Date (Optional)")) {
//                    Toggle("Set Due Date", isOn: $showDatePicker.animation())
//                    
//                    if showDatePicker {
//                        DatePicker(
//                            "Due Date",
//                            selection: Binding<Date>(
//                                get: { self.dueDate ?? Date() },
//                                set: { self.dueDate = $0 }
//                            ),
//                            displayedComponents: [.date, .hourAndMinute]
//                        )
//                    }
//                }
//                
//                // MARK: Tag Field
//                Section(header: Text("Tag (Optional)")) {
//                    TextField("Tag", text: $tag)
//                        .autocapitalization(.words)
//                }
//                
//                // MARK: Action Buttons
//                Section {
//                    Button(action: saveTask) {
//                        HStack {
//                            Spacer()
//                            Text("Save")
//                                .bold()
//                            Spacer()
//                        }
//                    }
//                    .foregroundColor(.white)
//                    .listRowBackground(Color.blue)
//                    
//                    Button(action: cancel) {
//                        HStack {
//                            Spacer()
//                            Text("Cancel")
//                            Spacer()
//                        }
//                    }
//                    .foregroundColor(.red)
//                }
//            }
//            .navigationBarTitle("Add New Task", displayMode: .inline)
//            .alert(isPresented: $showValidationAlert) {
//                Alert(
//                    title: Text("Cannot Save Task"),
//                    message: Text(validationMessage),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
//        }
//    }
//    
//    // MARK: - Actions
//    private func saveTask() {
//        guard validate() else { return }
//        
//        // Create task entity and send to intent
//        intent.addTask(
//            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
//            dueDate: dueDate,
//            tag: tag.isEmpty ? nil : tag.trimmingCharacters(in: .whitespacesAndNewlines)
//        )
//        
//        // Reset form after successful add
//        resetForm()
//    }
//    
//    private func cancel() {
//        isPresented = false
//    }
//    
//    // MARK: - Validation
//    private func validate() -> Bool {
//        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        if trimmedTitle.isEmpty {
//            validationMessage = "Task title cannot be empty"
//            showValidationAlert = true
//            return false
//        }
//        
//        return true
//    }
//    
//    // MARK: - Helpers
//    private func resetForm() {
//        title = ""
//        dueDate = nil
//        tag = ""
//        showDatePicker = false
//        isPresented = false
//    }
//    
//    private func setupSubscribers() {
//        // Subscribe to task add response from intent
//        $intent.$taskAddResponse
//            .dropFirst() // Skip initial nil value
//            .receive(on: RunLoop.main)
//            .sink { [weak self] response in
//                guard let self = self, let response = response else { return }
//                
//                if case .failure(let error) = response {
//                    self.validationMessage = error.localizedDescription
//                    self.showValidationAlert = true
//                }
//            }
//            .store(in: &cancellables)
//    }
//}
//
//// MARK: - Preview
//struct AddTaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock intent for preview
//        let mockIntent = TaskListIntent(interactor: MockTaskInteractor())
//        
//        return AddTaskView(
//            intent: mockIntent,
//            isPresented: .constant(true)
//        )
//    }
//}
