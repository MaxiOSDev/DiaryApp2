//
//  DiaryFetchedResultsController.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit
import CoreData

// The FetchedResultsController
class DiaryFetchedResultsController: NSFetchedResultsController<Entry>, NSFetchedResultsControllerDelegate {
    private let tableView: UITableView
    
    var dataSource: DiaryListDataSource!
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView) {
        self.tableView = tableView
        super.init(fetchRequest: Entry.fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.delegate = self
        
        tryFetch()
    }
    
    func tryFetch() {
        do {
            try performFetch() // try to Perform that fetch!
        } catch {
            print("Unresolved error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update, .move:
            print("Datasource \(dataSource)") // Sometimes it would show up as nil when using unit test
            if let dataSource = dataSource {
                if let searchMode = dataSource.inSearchMode { // Checks if in search mode first.
                    if searchMode {
                        if indexPath == nil {
                            guard let indexPath = indexPath else { return }
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    } else {
                        guard let indexPath = indexPath else { return }
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

