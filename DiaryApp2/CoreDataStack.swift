//
//  CoreDataStack.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import Foundation
import CoreData

// The Stack

class CoreDataStack {
    
    static let sharedInstance = CoreDataStack()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistantContainer
        return container.viewContext
    }()
    
    private lazy var persistantContainer: NSPersistentContainer = { // Now When it came to unit testing, these turorials never used container and idk why.
        let container = NSPersistentContainer(name: "DiaryApp2")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
}

extension NSManagedObjectContext {
    func saveChanges() {
        if self.hasChanges {
            do {
                try save()
            } catch {
                fatalError("Error \(error.localizedDescription)")
            }
        }
    }
    
    
}

