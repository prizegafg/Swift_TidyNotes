//
//  TaskListIntent.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 29/04/25.
//

import Foundation
import Combine

/// State objek untuk TaskList yang akan digunakan oleh View
final class TaskListState: ObservableObject {
    /// Daftar task yang ditampilkan
    @Published var tasks: [TaskEntity] = []
    
    /// State loading untuk menampilkan indikator loading
    @Published var isLoading: Bool = false
    
    /// Error yang terjadi (jika ada)
    @Published var error: TaskError? = nil
    
    /// Filter yang aktif (untuk pengembangan selanjutnya)
    @Published var activeFilter: TaskFilter = .all
}

/// Enum untuk filter task
enum TaskFilter {
    case all
    case active
    case completed
    case dueToday
    case overdue
    case byTag(TaskTag)
}

/// Intent/Presenter untuk TaskList
final class TaskListIntent: ObservableObject {
    /// State yang akan diobservasi oleh View
    @Published private(set) var state = TaskListState()
    
    private let interactor: TaskListInteractorProtocol
    private let router: TaskListRouter
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializer dengan dependency injection
    init(
        interactor: TaskListInteractorProtocol = TaskListInteractor(),
        router: TaskListRouter = TaskListRouter()
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    /// Mengambil daftar task dari interactor
    func fetchTasks() {
        state.isLoading = true
        state.error = nil
        
        interactor.fetchTasks()
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.state.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self.state.error = error
                    }
                },
                receiveValue: { [weak self] tasks in
                    guard let self = self else { return }
                    self.state.tasks = tasks
                    self.applyFilter()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Toggle status completed dari task
    func toggleTaskCompletion(task: TaskEntity) {
        interactor.toggleTaskCompletion(task: task)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state.error = error
                    }
                },
                receiveValue: { [weak self] updatedTask in
                    guard let self = self else { return }
                    
                    // Update task dalam array
                    if let index = self.state.tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                        self.state.tasks[index] = updatedTask
                    }
                    
                    self.applyFilter()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Menambahkan task baru
    func addTask(_ task: TaskEntity) {
        interactor.addTask(task)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state.error = error
                    }
                },
                receiveValue: { [weak self] newTask in
                    guard let self = self else { return }
                    self.state.tasks.append(newTask)
                    self.applyFilter()
                }
            )
            .store(in: &cancellables)
    }
    
    /// Menghapus task
    func deleteTask(id: UUID) {
        interactor.deleteTask(id: id)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.state.error = error
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.state.tasks.removeAll { $0.id == id }
                }
            )
            .store(in: &cancellables)
    }
    
    /// Set filter aktif dan apply filter
    func setFilter(_ filter: TaskFilter) {
        state.activeFilter = filter
        applyFilter()
    }
    
    /// Navigasi ke detail task
    func navigateToTaskDetail(task: TaskEntity) {
        router.navigateToTaskDetail(task: task)
    }
    
    /// Navigasi ke layar tambah task
    func navigateToAddTask() {
        router.navigateToAddTask()
    }
    
    /// Menerapkan filter pada daftar task
    private func applyFilter() {
        // Implementasi filter untuk pengembangan selanjutnya
        // Untuk saat ini hanya menyimpan tasks tanpa filtering
        
        /* Contoh implementasi filter:
        
        let filteredTasks: [TaskEntity]
        let today = Calendar.current.startOfDay(for: Date())
        
        switch state.activeFilter {
        case .all:
            filteredTasks = state.tasks
        case .active:
            filteredTasks = state.tasks.filter { !$0.isCompleted }
        case .completed:
            filteredTasks = state.tasks.filter { $0.isCompleted }
        case .dueToday:
            filteredTasks = state.tasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDate(dueDate, inSameDayAs: today)
            }
        case .overdue:
            filteredTasks = state.tasks.filter { task in
                guard let dueDate = task.dueDate, !task.isCompleted else { return false }
                return dueDate < today
            }
        case .byTag(let tag):
            filteredTasks = state.tasks.filter { $0.tag == tag }
        }
        
        state.filteredTasks = filteredTasks
        */
    }
    
    /// Reset kesalahan/error
    func resetError() {
        state.error = nil
    }
    
    /// Membersihkan resources saat object deinit
    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
