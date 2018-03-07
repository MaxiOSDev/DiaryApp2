//
//  Diary_AppTests.swift
//  Diary AppTests
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//
import XCTest
import CoreData
import UIKit
@testable import DiaryApp2

class Diary_AppTests: XCTestCase {
    
    // The core data stack within here
    var persisentStore: NSPersistentStore!
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectModel: NSManagedObjectModel!
    var stack = CoreDataStack.sharedInstance // Singlton
    var fakeEntry: Entry! // Fake Entry
    var tableView = UITableView() // TableView needed for the fetchResultsController
    var inSearchMode = false
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        return managedObjectContext
    }()
    
    lazy var fetchedResultsController: DiaryFetchedResultsController = {
        let controller = DiaryFetchedResultsController(managedObjectContext: managedObjectContext, tableView: tableView)
        return controller
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch  {
            fatalError()
        }
        
        managedObjectContext = stack.managedObjectContext // Sets the managedObjectContext to the stack's managedObjectContext
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        deleteEntry() // Deletes the entry during teardown if any, and sets everything else to nil
        managedObjectModel = nil
        persisentStore = nil
        storeCoordinator = nil
        super.tearDown()
    }
    // Test Entry Creation
    func testEntryCreation() {
        // Asserts that the fetched objects before are 0
        XCTAssert(fetchedResultsController.fetchedObjects?.count == 0, "Found more than 0 entries")
        createEntry() // Creates entry
        // Asserts that the fetched object before are 1 because entry was created
        XCTAssert(fetchedResultsController.fetchedObjects?.count == 1, "More or less than 1 entry found")
        deleteEntry() // Deletes entry for next test
    }
    // Test Entry Edit
    func testEntryEdit() {
        // Creates entry with text and other properties
        createEntry()
        // Asserts that the current non-edited entry is what it was assigned
        XCTAssert(fakeEntry.text == "Test text Uno", "Text Incorrect")
        editEntry() // Then Edits entry
        // Asserts that the edited entry's text has been edited and set with the text provided
        XCTAssert(fakeEntry.text == "Test text Uno Edited", "Text has not changed or text incorrect")
        deleteEntry() // Deletes entry for next test
    }
    
    // Test Entry Deletion
    func testDeleteEntry() {
        // Asserts that there is an entry already in memory
        XCTAssert(fetchedResultsController.fetchedObjects?.count == 1, "More or less than 1 entry found")
        deleteEntry() // Then deletes
        // Asserts that there is no more entries after deletion
        XCTAssert(fetchedResultsController.fetchedObjects?.count == 0, "DeleteFailed, more than 0 entries found")
        
    }
    // Helpers
    
    func createEntry() {
        fakeEntry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: stack.managedObjectContext) as! Entry
        fakeEntry.text = "Test text Uno"
        fakeEntry.location = "Test Fake Location"
        fakeEntry.status = "good"
        let date = Date()
        let currentDate = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = currentDate.component(.weekday, from: date)
        dateComponents.day = currentDate.component(.day, from: date)
        dateComponents.month = currentDate.component(.month, from: date)
        if let currentEntryDate = currentDate.date(from: dateComponents) {
            fakeEntry.date = currentEntryDate as NSDate
        }
        fakeEntry.dateHelper = Date() as NSDate
        let photo = #imageLiteral(resourceName: "icn_noimage")
        let data = UIImageJPEGRepresentation(photo, 1.0)! as NSData
        fakeEntry.photo.append(data)
        managedObjectContext.saveChanges()
        fetchedResultsController.tryFetch()
    }
    
    func editEntry() {
        fakeEntry.text = "Test text Uno Edited"
        fakeEntry.location = "Test Fake Location Edited"
        fakeEntry.status = "bad"
        let date = Date()
        let currentDate = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = currentDate.component(.weekday, from: date)
        dateComponents.day = currentDate.component(.day, from: date)
        dateComponents.month = currentDate.component(.month, from: date)
        if let currentEntryDate = currentDate.date(from: dateComponents) {
            fakeEntry.date = currentEntryDate as NSDate
        }
        fakeEntry.dateHelper = Date() as NSDate
        let photo = #imageLiteral(resourceName: "icn_bad")
        let data = UIImageJPEGRepresentation(photo, 1.0)! as NSData
        fakeEntry.photo.append(data)
        managedObjectContext.saveChanges()
        fetchedResultsController.tryFetch()
    }
    
    
    func deleteEntry() {
        if let entry = fetchedResultsController.fetchedObjects?.first {
            stack.managedObjectContext.delete(entry)
            stack.managedObjectContext.saveChanges()
        }
    }
    
    
}
