//
//  DiaryListController.swift
//  Diary App
//
//  Created by Max Ramirez on 2/22/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit
import CoreData
import SHSearchBar

class DiaryListController: UIViewController {
    
    // IBOutlets
    
    @IBOutlet weak var todayDateLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var composeButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainerView: UIView!
    
    let managedObjectContext = CoreDataStack().managedObjectContext // The mangedObjectContext
    
    var searchBar1: SHSearchBar! // Custom Pod searchBar
    var rasterSize: CGFloat = 5.0
    var viewConstraints: [NSLayoutConstraint]? // For Search Bar
    // TableView Lazy Datasource
    lazy var dataSource: DiaryListDataSource = {
        return DiaryListDataSource(tableView: self.tableView, context: self.managedObjectContext)
    }()
    // Search bar constraint setup
    func setupLayoutConstraints() {
        let searchBarHeight: CGFloat = 25
        
        let constraints = [searchBar1.topAnchor.constraint(equalTo: searchBarContainerView.layoutMarginsGuide.topAnchor, constant: 0),
                           searchBar1.leadingAnchor.constraint(equalTo: searchBarContainerView.layoutMarginsGuide.leadingAnchor, constant: 0),
                           searchBar1.trailingAnchor.constraint(equalTo: searchBarContainerView.layoutMarginsGuide.trailingAnchor, constant: 0),
                           searchBar1.heightAnchor.constraint(equalToConstant: searchBarHeight)]
        
        NSLayoutConstraint.activate(constraints)
        if viewConstraints != nil {
            UIView.animate(withDuration: 0.25, animations: {
                self.searchBarContainerView.layoutIfNeeded()
            })
        }
        viewConstraints = constraints
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource // Setting the datasource
        tableView.delegate = self // Setting the delegate
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 195 // For self resizing cells
        dataSource.fetchedResultsController.dataSource = dataSource
        definesPresentationContext = true
        // Some search bar layout
        let leftView1 = imageViewWithIcon(#imageLiteral(resourceName: "icon-search-1"), rasterSize: rasterSize)
        searchBar1 = defaultSearchBar(withRasterSize: rasterSize, leftView: leftView1, rightView: nil, delegate: dataSource)
        searchBarContainerView.addSubview(searchBar1)
        setupLayoutConstraints()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            let raster: CGFloat = 22.0
            self?.rasterSize = raster
            
            
            var config = self?.searchBar1.config
            config?.cancelButtonTextAttributes = [.foregroundColor : UIColor.red]
            config?.rasterSize = raster
            self?.searchBar1.config = config!
            
            self?.setupLayoutConstraints()
        }
        
        setupViews()
        setNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func composeNewEntry(_ sender: Any) {
        self.performSegue(withIdentifier: "newEntry", sender: self)
    }
    
    
    
    // MARK: - Helper methods
    
    func setupViews() {
        monthYearLabel.text = setMonth(for: self.monthYearLabel) // Uses another helper method to set monthYearLabel
        setDateLabel()
    }
    
    // FIXME: - Can refactor code here!
    func setNavBar() {
        let date = Date()
        let currentDate = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = currentDate.component(.year, from: date)
        dateComponents.day = currentDate.component(.day, from: date)
        dateComponents.month = currentDate.component(.month, from: date)
        let currentEntryDate = currentDate.date(from: dateComponents)
        let myFormatter = DateFormatter()
        myFormatter.string(from: currentEntryDate!)
        myFormatter.dateFormat = "MMMM d'\(daySuffix(from: currentEntryDate!))', yyyy"
        let dateString = myFormatter.string(from: currentEntryDate!)
        navigationItem.title = dateString
    }
    
    func setDateLabel() {
        let date = Date()
        let currentDate = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.weekday = currentDate.component(.weekday, from: date)
        dateComponents.day = currentDate.component(.day, from: date)
        dateComponents.month = currentDate.component(.month, from: date)
        let currentEntryDate = currentDate.date(from: dateComponents)
        let myFormatter = DateFormatter()
        myFormatter.string(from: currentEntryDate!)
        myFormatter.dateFormat = "EEEE d'\(daySuffix(from: currentEntryDate!))' MMMM" // Example: Tuesday 20th Febuary
        let dateString = myFormatter.string(from: currentEntryDate!)
        todayDateLabel.text = dateString
    }
    
    // Custom helper that gets the suffix for the appropriate day of the month
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
    
    // Custom helper to set only month and year for label's text
    func setMonth(for label: UILabel) -> String {
        let date = Date()
        let currentDate = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = currentDate.component(.year, from: date)
        dateComponents.month = currentDate.component(.month, from: date)
        let currentMonth = currentDate.date(from: dateComponents)
        let myFormatter = DateFormatter()
        myFormatter.string(from: currentMonth!)
        myFormatter.dateFormat = "MMMM yyyy"
        let dateString = myFormatter.string(from: currentMonth!)
        return dateString
    }
    
    // Passing Data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newEntry" {
            let addEntryController = segue.destination as! DetailViewController
            addEntryController.managedObjectContext = self.managedObjectContext
            addEntryController.navigationItem.title = self.navigationItem.title
            
        } else if segue.identifier == "editEntry" {
            guard let detailVC = segue.destination as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow else { return }
            // TableView Datasource needs to know when in search mode aka when using search bar and when not
            if dataSource.inSearchMode! {
                let entry = dataSource.filteredEntry
                detailVC.managedObjectContext = self.managedObjectContext
                detailVC.entry = entry
                detailVC.imagesListArray = dataSource.imagesListArray
                detailVC.navigationItem.title = self.navigationItem.title
            } else {
                let entry = dataSource.object(at: indexPath)
                detailVC.managedObjectContext = self.managedObjectContext
                detailVC.entry = entry
                detailVC.imagesListArray = dataSource.imagesListArray
                detailVC.navigationItem.title = self.navigationItem.title
            }
            
        }
    }
}

extension DiaryListController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editEntry", sender: self)
    }
}

extension DiaryListController {
    
    // MARK: - SHSearchBar Helper Functions
    func defaultSearchBar(withRasterSize rasterSize: CGFloat, leftView: UIView?, rightView: UIView?, delegate: SHSearchBarDelegate, useCancelButton: Bool = true) -> SHSearchBar {
        var config = defaultSearchBarConfig(rasterSize)
        config.leftView = leftView
        config.rightView = rightView
        config.useCancelButton = useCancelButton
        
        if leftView != nil {
            config.leftViewMode = .always
        }
        
        if rightView != nil {
            config.rightViewMode = .unlessEditing
        }
        
        let bar = SHSearchBar(config: config)
        bar.delegate = delegate
        bar.placeholder = NSLocalizedString("search for entries", comment: "")
        bar.updateBackgroundImage(withRadius: 6, corners: [.allCorners], color: UIColor.white)
        bar.layer.shadowColor = UIColor.black.cgColor
        bar.layer.shadowOffset = CGSize(width: 0, height: 3)
        bar.layer.shadowRadius = 5
        bar.layer.shadowOpacity = 0.25
        return bar
    }
    
    func defaultSearchBarConfig(_ rasterSize: CGFloat) -> SHSearchBarConfig {
        var config: SHSearchBarConfig = SHSearchBarConfig()
        config.rasterSize = rasterSize
        
        config.cancelButtonTextAttributes = [.foregroundColor : UIColor.darkGray]
        config.textContentType = UITextContentType.fullStreetAddress.rawValue
        config.textAttributes = [.foregroundColor : UIColor.gray]
        return config
    }
    
    func imageViewWithIcon(_ icon: UIImage, rasterSize: CGFloat) -> UIImageView {
        let imgView = UIImageView(image: icon)
        imgView.frame = CGRect(x: 0, y: 0, width: icon.size.width + rasterSize * 2.0, height: icon.size.height)
        imgView.contentMode = .center
        imgView.tintColor = UIColor(red: 0.75, green: 0, blue: 0, alpha: 1)
        return imgView
    }
    
    
}
