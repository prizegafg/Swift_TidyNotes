//
//  TaskSyncServices.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 02/07/25.
//

import FirebaseFirestore
import RealmSwift

struct TaskSyncService {
    static let shared = TaskSyncService()
    
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
        let db = Firestore.firestore()
        db.collection("tasks")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    print("Error fetching: \(error?.localizedDescription ?? "-")")
                    completion(false)
                    return
                }
                var newTasks: [TaskEntity] = []
                for doc in documents {
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
                    else { continue }
                    let dueDate = (data["dueDate"] as? Timestamp)?.dateValue() ?? data["dueDate"] as? Date
                    let isReminderOn = data["isReminderOn"] as? Bool ?? false
                    let reminderDate = (data["reminderDate"] as? Timestamp)?.dateValue() ?? data["reminderDate"] as? Date
                    let imagePath = data["imagePath"] as? String
                    
                    let task = TaskEntity(
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
                    newTasks.append(task)
                }
                let realm = try! Realm()
                try! realm.write {
                    let oldTasks = realm.objects(TaskEntity.self).filter("userId == %@", userId)
                    realm.delete(oldTasks)
                    realm.add(newTasks)
                }
                completion(true)
            }
    }
    
    func clearLocalTasks() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(TaskEntity.self))
        }
    }
    
}
