//
//  DiaryListDataSource.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit
import CoreData
import SHSearchBar

class DiaryListDataSource: NSObject, UITableViewDataSource {
    
    // Properties
    private let tableView: UITableView
    let context: NSManagedObjectContext
    var imagesListArray = [UIImage]()
    var filteredData = [Entry]()
    var inSearchMode: Bool? = false
    var filteredEntry: Entry?
    // Lazily loaded fetched results controller
    lazy var fetchedResultsController: DiaryFetchedResultsController = {
        return DiaryFetchedResultsController(managedObjectContext: self.context, tableView: self.tableView)
    }()
    
    init(tableView: UITableView, context: NSManagedObjectContext) {
        self.tableView = tableView
        self.context = context
    }
    
    func object(at indexPath: IndexPath) -> Entry {
        return fetchedResultsController.object(at: indexPath)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        if inSearchMode! {
            return filteredData.count // Only show number of rows for filtered data when in search mode
        }
        
        return section.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let diaryEntryCell = tableView.dequeueReusableCell(withIdentifier: "DiaryEntryCell", for: indexPath) as! DiaryEntryCell
        
        if inSearchMode! {
            print("In search Mode")
            // Configures each cell for when in search mode
            return configureCell(diaryEntryCell, at: indexPath)
        } else {
            return configureCell(diaryEntryCell, at: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let entry = fetchedResultsController.object(at: indexPath)
        context.delete(entry)
        context.saveChanges() // Save the changes when an entry has been deleted
    }
    
    // Helpers
    private func configureCell(_ cell: DiaryEntryCell, at indexPath: IndexPath) -> UITableViewCell {
        
        if filteredData.count > 0 {
            let entry = filteredData[indexPath.row]
            filteredEntry = entry
            cell.entryTextLabel.text = entry.text
            
            // Checks and sets labels and hides as necessary
            if cell.addLocationLabel != nil && cell.geolocateIcon != nil && cell.statusImage != nil {
                if entry.location != nil {
                    cell.addLocationLabel.text = entry.location
                } else {
                    cell.addLocationLabel.isHidden = true
                    cell.geolocateIcon.isHidden = true
                }
                
                // Checks and sets status depending on the stored string in data, either bad, average, or good then sets image appropriately
                if entry.status != nil {
                    if entry.status == "bad" {
                        cell.statusImage.image = #imageLiteral(resourceName: "icn_bad")
                    } else if entry.status == "average" {
                        cell.statusImage.image = #imageLiteral(resourceName: "icn_average")
                    } else if entry.status == "good" {
                        cell.statusImage.image = #imageLiteral(resourceName: "icn_happy")
                    }
                    
                } else {
                    cell.statusImage.isHidden = true
                }
                
            }
            
            // Configures date
            let entryDate = entry.date as Date
            let myFormatter = DateFormatter()
            myFormatter.string(from: entryDate)
            myFormatter.dateFormat = "EEEE d'\(daySuffix(from: entryDate))' MMMM"
            let dateString = myFormatter.string(from: entryDate)
            cell.dateLabel.text = dateString
            
            self.imagesListArray = entry.image
            
            // The animation
            cell.entryImage.animationImages = self.imagesListArray
            cell.entryImage.animationDuration = 3.5
            cell.entryImage.startAnimating()
            
            return cell
            
        } else {
            
            let entry = fetchedResultsController.object(at: indexPath)
            cell.entryTextLabel.text = entry.text
            // Appropriate label and button sets
            if cell.addLocationLabel != nil && cell.geolocateIcon != nil && cell.statusImage != nil {
                if entry.location != nil {
                    cell.addLocationLabel.text = entry.location
                } else {
                    cell.addLocationLabel.isHidden = true
                    cell.geolocateIcon.isHidden = true
                }
                
                // Staus set
                if entry.status != nil {
                    if entry.status == "bad" {
                        cell.statusImage.image = #imageLiteral(resourceName: "icn_bad")
                    } else if entry.status == "average" {
                        cell.statusImage.image = #imageLiteral(resourceName: "icn_average")
                    } else if entry.status == "good" {
                        cell.statusImage.image = #imageLiteral(resourceName: "icn_happy")
                    }
                } else {
                    cell.statusImage.isHidden = true
                }
            }
            // Date sets
            let entryDate = entry.date as Date
            let myFormatter = DateFormatter()
            myFormatter.string(from: entryDate)
            myFormatter.dateFormat = "EEEE d'\(daySuffix(from: entryDate))' MMMM"
            let dateString = myFormatter.string(from: entryDate)
            cell.dateLabel.text = dateString
            // Image set
            imagesListArray = entry.image
            // Animation set
            cell.entryImage.animationImages = imagesListArray
            cell.entryImage.animationDuration = 3.5
            cell.entryImage.startAnimating()
            return cell
        }
        
    }
    // That amazing custom helper
    func daySuffix(from date: Date) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        switch dayOfMonth {
        case 1, 21, 31: return "st"
        case 2, 22: return "nd"
        case 3, 23: return "rd"
        default: return "th"
        }
    }
    
}

extension DiaryListDataSource: SHSearchBarDelegate {
    // Search Bar Delegate
    func searchBar(_ searchBar: SHSearchBar, textDidChange text: String) {
        print(text)
        
        if text == "" {
            inSearchMode = false
            filteredData.removeAll()
            tableView.reloadData()
        } else {
            inSearchMode = true
            filteredData = (fetchedResultsController.fetchedObjects?.filter(({$0.text.lowercased().contains(text.lowercased())})))!
            
            tableView.reloadData()
        }
    }
    
}
