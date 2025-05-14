//
//  RealmManager.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 13/05/25.
//

import Foundation
import RealmSwift

final class RealmManager {
    static let shared = RealmManager()

    private let realm: Realm

    private init() {
        do {
            let fileManager = FileManager.default
            let folderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TidyNotes")

            if !fileManager.fileExists(atPath: folderURL.path) {
                try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }

            let realmFileURL = folderURL.appendingPathComponent("tidynotes.realm")

            let config = Realm.Configuration(
                fileURL: realmFileURL,
                schemaVersion: 2,
                migrationBlock: { _, _ in },
                deleteRealmIfMigrationNeeded: false
            )
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            print("✅ Realm path:", realm.configuration.fileURL?.path ?? "Unavailable")
        } catch {
            fatalError("❌ Realm initialization failed: \(error)")
        }
    }

    // MARK: - CRUD Operations

    func fetchAllTasks() -> [TaskEntity] {
        let results = realm.objects(RealmTaskObject.self)
        return results.map { $0.toEntity() }
    }

    func fetchTask(by id: UUID) -> TaskEntity? {
        realm.object(ofType: RealmTaskObject.self, forPrimaryKey: id.uuidString)?.toEntity()
    }

    func addOrUpdateTask(_ task: TaskEntity) {
        let object = RealmTaskObject(entity: task)
        try? realm.write {
            realm.add(object, update: .modified)
        }
    }

    func deleteTask(_ task: TaskEntity) {
        guard let object = realm.object(ofType: RealmTaskObject.self, forPrimaryKey: task.id.uuidString) else { return }
        try? realm.write {
            realm.delete(object)
        }
    }

    func deleteAllTasks() {
        let all = realm.objects(RealmTaskObject.self)
        try? realm.write {
            realm.delete(all)
        }
    }
    
    func fetchAllProjects() -> [ProjectEntity] {
        realm.objects(RealmProjectObject.self).map { $0.toEntity() }
    }

    func fetchProject(by id: UUID) -> ProjectEntity? {
        realm.object(ofType: RealmProjectObject.self, forPrimaryKey: id.uuidString)?.toEntity()
    }

    func addOrUpdateProject(_ project: ProjectEntity) {
        let object = RealmProjectObject(entity: project)
        try? realm.write {
            realm.add(object, update: .modified)
        }
    }

    func deleteProject(_ project: ProjectEntity) {
        guard let obj = realm.object(ofType: RealmProjectObject.self, forPrimaryKey: project.id.uuidString) else { return }
        try? realm.write {
            realm.delete(obj)
        }
    }

    func deleteAllProjects() {
        let all = realm.objects(RealmProjectObject.self)
        try? realm.write {
            realm.delete(all)
        }
    }
    
    func disableReminder(for id: String) {
        guard let object = realm.object(ofType: RealmTaskObject.self, forPrimaryKey: id) else { return }
        try? realm.write {
            object.isReminderOn = false
            object.reminderDate = nil
        }
    }

}
