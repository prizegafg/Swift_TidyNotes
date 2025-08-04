//
//  TaskSyncServices.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import FirebaseFirestore
import RealmSwift

struct TaskService {
    static let shared = TaskService()
    private let db = Firestore.firestore()
    
    func syncTasksToFirestore(for userId: String) {
        let db = Firestore.firestore()
        let realm = try! Realm()
        let tasks = realm.objects(TaskEntity.self).filter("userId == %@", userId)
        let batch = db.batch()
        let tasksRef = db.collection("tasks")
        
        for task in tasks {
            let docRef = tasksRef.document(task.id.uuidString)
            batch.setData([
                "id": task.id.uuidString,
                "userId": task.userId,
                "title": task.title,
                "descriptionText": task.descriptionText,
                "isPriority": task.isPriority,
                "createdAt": task.createdAt,
                "dueDate": task.dueDate as Any,
                "isReminderOn": task.isReminderOn,
                "reminderDate": task.reminderDate as Any,
                "imagePath": task.imagePath as Any,
                "status": task.status.rawValue
            ], forDocument: docRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Sync to Firestore failed: \(error.localizedDescription)")
            } else {
                print("Sync to Firestore succeeded.")
            }
        }
    }
    
    func fetchTasksFromFirestore(for userId: String, completion: @escaping ([TaskEntity]) -> Void) {
        let db = Firestore.firestore()
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching: \(error?.localizedDescription ?? "-")")
                    completion([])
                    return
                }
                let tasks: [TaskEntity] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let idStr = data["id"] as? String,
                        let id = UUID(uuidString: idStr),
                        let userId = data["userId"] as? String,
                        let title = data["title"] as? String,
                        let descriptionText = data["descriptionText"] as? String,
                        let isPriority = data["isPriority"] as? Bool,
                        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? data["createdAt"] as? Date,
                        let statusStr = data["status"] as? String,
                        let status = TaskStatus(rawValue: statusStr)
                    else { return nil }
                    let dueDate = (data["dueDate"] as? Timestamp)?.dateValue() ?? data["dueDate"] as? Date
                    let isReminderOn = data["isReminderOn"] as? Bool ?? false
                    let reminderDate = (data["reminderDate"] as? Timestamp)?.dateValue() ?? data["reminderDate"] as? Date
                    let imagePath = data["imagePath"] as? String
                    return TaskEntity(
                        id: id,
                        userId: userId,
                        title: title,
                        descriptionText: descriptionText,
                        isPriority: isPriority,
                        createdAt: createdAt,
                        dueDate: dueDate,
                        isReminderOn: isReminderOn,
                        reminderDate: reminderDate,
                        imagePath: imagePath,
                        status: status
                    )
                }
                completion(tasks)
            }
    }
    
    func fetchTasksFromFirestoreAndReplaceRealm(for userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard error == nil, let documents = snapshot?.documents else {
                    print("❌ Firestore fetch error: \(error?.localizedDescription ?? "-")")
                    completion(false)
                    return
                }

                let tasks: [TaskEntity] = documents.compactMap { doc in
                    let data = doc.data()
                    guard
                        let userId = data["userId"] as? String,
                        let title = data["title"] as? String
                    else { return nil }
                    let id = UUID(uuidString: doc.documentID) ?? UUID()
                    let descriptionText = data["descriptionText"] as? String ?? ""
                    let isPriority = data["isPriority"] as? Bool ?? false
                    let statusRaw = data["status"] as? String ?? TaskStatus.todo.rawValue
                    let status = TaskStatus(rawValue: statusRaw) ?? .todo
                    let createdAt: Date = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    let dueDate: Date? = (data["dueDate"] as? Timestamp)?.dateValue()
                    let isReminderOn = data["isReminderOn"] as? Bool ?? false
                    let reminderDate: Date? = (data["reminderDate"] as? Timestamp)?.dateValue()
                    let imagePath = data["imagePath"] as? String

                    return TaskEntity(
                        id: id,
                        userId: userId,
                        title: title,
                        descriptionText: descriptionText,
                        isPriority: isPriority,
                        createdAt: createdAt,
                        dueDate: dueDate,
                        isReminderOn: isReminderOn,
                        reminderDate: reminderDate,
                        imagePath: imagePath,
                        status: status
                    )
                }

                do {
                    let realm = try Realm()
                    let oldTasks = realm.objects(TaskEntity.self).filter("userId == %@", userId)
                    try realm.write {
                        realm.delete(oldTasks)
                        for task in tasks {
                            realm.add(task, update: .all)
                        }
                    }
                    completion(true)
                } catch {
                    print("❌ Realm error: \(error)")
                    completion(false)
                }
            }
    }
    
    func deleteTaskInFirestore(taskId: UUID, completion: @escaping (Bool) -> Void) {
        db.collection("tasks").document(taskId.uuidString)
            .delete { error in
                if let error = error {
                    print("Firestore delete error:", error.localizedDescription)
                    completion(false)
                } else {
                    print("✅ Firestore task deleted:", taskId)
                    completion(true)
                }
            }
    }

    
    func clearLocalTasks() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(TaskEntity.self))
        }
    }
    
}
