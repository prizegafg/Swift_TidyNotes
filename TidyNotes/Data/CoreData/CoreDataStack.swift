//
//  CoreDataStack.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 08/05/25.
//

import Foundation
import CoreData

final class CoreDataStack {
    
    /// Shared instance untuk Core Data stack
    static let shared = CoreDataStack()
    
    /// Core Data container yang berisi model dan context
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TidyNotes")
        
        // Load persistent stores asynchronously
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle error - typically you would present an alert or log failure
                fatalError("Unresolved error loading persistent stores: \(error), \(error.userInfo)")
            }
            
            print("✅ Core Data store loaded successfully")
            print("📂 Store URL: \(storeDescription.url?.absoluteString ?? "unknown")")
        }
        
        // Configure container
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Set up for better performance
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()
    
    /// Main UI context
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        // Private initializer to enforce singleton pattern
        setupNotifications()
    }
    
    /// Setup notifications for Core Data changes
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managedObjectContextWillSave),
            name: .NSManagedObjectContextWillSave,
            object: nil
        )
    }
    
    /// Handle CoreData save notifications
    @objc private func managedObjectContextDidSave(notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        
        // If saved context is not the main context, merge changes into view context
        if context != viewContext {
            viewContext.perform {
                self.viewContext.mergeChanges(fromContextDidSave: notification)
                print("📊 Changes from background context merged into main context")
            }
        } else {
            print("✅ Main context saved successfully")
        }
    }
    
    /// Pre-save notification handler
    @objc private func managedObjectContextWillSave(notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        
        // Perform any pre-save validation or processing if needed
        print("⏳ Context about to save: \(context == viewContext ? "Main" : "Background")")
    }
    
    /// Create a new background context for background operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Perform work on a background context
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            block(context)
        }
    }
    
    /// Save context with error handling
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                if context == viewContext {
                    print("✅ Main context saved")
                } else {
                    print("✅ Background context saved")
                }
            } catch {
                let nsError = error as NSError
                print("❌ Core Data error saving context: \(nsError), \(nsError.userInfo)")
                #if DEBUG
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
                #endif
            }
        }
    }
    
    /// Save main view context
    func saveViewContext() {
        saveContext(viewContext)
    }
    
    /// Reset the Core Data stack
    func resetCoreDataStack() {
        // Reset the persistent store coordinator
        for store in persistentContainer.persistentStoreCoordinator.persistentStores {
            do {
                try persistentContainer.persistentStoreCoordinator.remove(store)
            } catch {
                print("❌ Failed to remove persistent store: \(error)")
            }
        }
        
        // Reset the container
        persistentContainer = NSPersistentContainer(name: "TidyNotes")
        
        // Load persistent stores again
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("❌ Failed to load stores after reset: \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data stack reset successfully")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
