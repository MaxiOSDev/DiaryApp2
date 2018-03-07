//
//  DetailViewController.swift
//  DiaryApp2
//
//  Created by Max Ramirez on 3/7/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import Foundation
//
//  DetailViewController.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import ImagePicker
import Lightbox

class DetailViewController: UIViewController, UITextViewDelegate, LocationPermissionsDelegate, LocationManagerDelegate, ImagePickerDelegate {
    
    // MARK: - IBOutlets
    // Month/Year View
    @IBOutlet weak var monthYearLabel: UILabel!
    
    // Diary Entry View
    @IBOutlet weak var entryImageButton: UIButtonX!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var geolocateIcon: UIImageView!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Status View
    @IBOutlet weak var badButton: UIButton!
    @IBOutlet weak var averageButton: UIButton!
    @IBOutlet weak var goodButton: UIButton!
    
    // Entry TableView List
    @IBOutlet weak var entryListTableView: UITableView!
    
    // Lazy loaded location Manager thanks @pasan for the excellent course :)
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: self, permissionDelegate: self)
    }()
    // Lazily loaded Datasource, using same datasource but cells will be a tad different as per the mockups.
    lazy var dataSource: DiaryListDataSource = {
        return DiaryListDataSource(tableView: self.entryListTableView, context: self.managedObjectContext)
    }()
    // I use an imageArray to hold the pictures and display them with animation
    var imagesListArray = [UIImage]()
    var entry: Entry? // The entry if there is one
    var managedObjectContext: NSManagedObjectContext! // Always needed
    var entryDate: Date! // Always needed
    var dateHelper: Date! // Always needed
    var status: String? // There may not be a status
    let configuration = Configuration() // Part of the ImagePicker Pod
    // Custom Pod ImagePicker
    lazy var imagePicker: ImagePickerController = {
        return ImagePickerController(configuration: self.configuration)
    }()
    
    public var imageAssets: [UIImage] {
        return AssetManager.resolveAssets(imagePicker.stack.assets)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Just a bunch of tablview setup
        self.entryTextView.delegate = self
        monthYearLabel.text = setMonth(for: self.monthYearLabel)
        self.entryListTableView.dataSource = dataSource
        self.entryListTableView.delegate = self
        self.entryListTableView.rowHeight = UITableViewAutomaticDimension
        self.entryListTableView.estimatedRowHeight = 195
        print("Amount in imagesListArray \(imagesListArray.count)")
        dataSource.fetchedResultsController.dataSource = dataSource
        // Checks if the entry was passed through prepareForSegue in Master VC
        // If so, then it sets it
        if self.entry != nil {
            if let entry = entry {
                entryTextView.text = entry.text
                entryDate = entry.date as Date!
                imagesListArray = entry.image
                entry.status = status
                
                entryImageButton.imageView?.animationImages = imagesListArray
                entryImageButton.imageView?.animationDuration = 3.5
                entryImageButton.imageView?.startAnimating()
            }
        }
        
        setDateLabel()
        setCharacterColor()
        
    }
    
    // MARK: - IB Actions
    @IBAction func addLocation(_ sender: Any) {
        requestLocationPermissions()
    }
    
    @IBAction func addPicture(_ sender: Any) {
        
        imagePicker.delegate = self
        imagePicker.imageLimit = 5 // Limits the amount of images a user can select in the ImagePicker Controller
        
        present(imagePicker, animated: true, completion: nil)
    }
    // Sets the status. I store an optional string into core data, and then do appropriate checks to set the image instead of storing an image
    @IBAction func setStatus(_ sender: UIButton) {
        if sender == badButton {
            status = "bad"
        } else if sender == averageButton {
            status = "average"
        } else if sender == goodButton {
            status = "good"
        }
        
        
    }
    
    // This IBAction does all the good stuff
    @IBAction func saveEntry(_ sender: Any) {
        guard let text = entryTextView.text, !text.isEmpty else { return } // Checks if the textview text is not empty and assigns it to a contant
        guard let location = addLocationButton.currentTitle, !location.isEmpty else { return } // Checks if location buttons title is not empty and assigns it to a constant
        
        // So Entries can be saved with edited version, checks if the entry was sent through prepareForSegue
        if self.entry != nil {
            if let oldEntry = self.entry {
                oldEntry.text = text
                oldEntry.date = entryDate as NSDate
                
                if addLocationButton.currentTitle != "Add Location" {
                    oldEntry.location = location
                }
                
                oldEntry.status = status
                
                oldEntry.photo.removeAll()
                for image in imagesListArray {
                    let metaData = UIImageJPEGRepresentation(image, 1.0)! as NSData
                    oldEntry.photo.append(metaData)
                }
                
                
                managedObjectContext.saveChanges() // Save that edited entry
            }
            
        } else {
            let entry = NSEntityDescription.insertNewObject(forEntityName: "Entry", into: managedObjectContext) as! Entry // New Entry
            entry.text = text
            
            if addLocationButton.currentTitle != "Add Location" { // Checks if location buttons curent title is not Add Location
                entry.location = location // Sets location only if location text changed
            }
            
            entry.date = entryDate as NSDate // Saves entry date that had date components set
            entry.dateHelper = dateHelper as NSDate // Saves a helper date in memory so They can be sorted properally
            entry.status = status // Sets status if there is any, it is optional
            
            // Checks images List array to see if there are any images in it
            if imagesListArray.count > 0 {
                for image in imagesListArray { // Loop through array then assign the metadata in core data
                    let metaData = UIImageJPEGRepresentation(image, 1.0)! as NSData
                    entry.photo.append(metaData)
                }
            } else {
                if let image = self.entryImageButton.currentImage { // If not, I store the placeholder... Feel like there is a better way
                    let metaData = UIImageJPEGRepresentation(image, 1.0)! as NSData
                    entry.photo.append(metaData)
                }
            }
            
            managedObjectContext.saveChanges() // Save that new entry!
            navigationController?.popToRootViewController(animated: true) // This automatically goes back to root view controller aka the master/diarlistVC on save.
        }
    }
    // Request user persmission for location services
    @objc func requestLocationPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
            locationManager.requestLocation()
        } catch LocationError.disallowedByUser {
            print("Disallowed By User")
        } catch let error {
            print("Location Authorization Error: \(error.localizedDescription)")
        }
    }
    
    // Image Picker Pod Protocol Stubs
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        // What I could have done here is present either the picture or an image gallary, but not needed for project, and it was time I did not have
    }
    // Where the magic happens
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagesListArray.removeAll()
        let images = imageAssets
        
        guard images.count > 0 else {
            print("No Images: \(images)")
            return }
        
        for image in images {
            
            imagesListArray.append(image) // Places image in imageListArray
        }
        // Animations! Thought it was a cool way to show a user can select more than 1 image for 1 entry
        self.entryImageButton.imageView?.animationImages = imagesListArray
        self.entryImageButton.imageView?.animationDuration = 3.5
        self.entryImageButton.imageView?.startAnimating()
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    func setDateLabel() {
        
        if entryDate != nil {
            print("Entry Date is nil")
            let date = entryDate!
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
            dateLabel.text = dateString
            
        } else {
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
            dateLabel.text = dateString
            entryDate = currentEntryDate // Could then use date formatter to insert text label in cell with date that is saved in data.
        }
        
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
    
    // Sets month and year for Month/Year label
    func setMonth(for label: UILabel) -> String {
        let date = Date()
        dateHelper = date
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
    
    // Using extension to load the changed color for certain text
    func setCharacterColor() {
        characterCountLabel.colorString(text: "0/200", coloredText: "0")
    }
    
    // Works at setting the limit of character's allowed in textView. Now I know how twitter does it.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        characterCountLabel.colorString(text: "\(newText.count)/200", coloredText: "\(newText.count)") // Changing text and color for certain text and character count
        return newText.count < 200
    }
    
    // MARK: - Location Protocol Stubs
    func authorizationSucceeded() {
        addLocationButton.isEnabled = true
    }
    
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus) {
        // Alerts user if application not authorized to use location services
        addLocationButton.isEnabled = false
        let alertController = UIAlertController(title: "Authorization Denied", message: "Please allow location services in settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // The following code is how I retreive the location name, street, city, state for the user.
    func obtainedCoordinates(_ coordinate: Coordinate) {
        let geoCoder = CLGeocoder()
        let latitude: CLLocationDegrees = coordinate.latitude
        let longitude: CLLocationDegrees = coordinate.longitude
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            if let locationName = placeMark.name {
                print(locationName)
            }
            
            if let street = placeMark.thoroughfare {
                if let city = placeMark.locality {
                    if let state = placeMark.administrativeArea {
                        self.addLocationButton.setTitle("\(street) - \(city), \(state)", for: .normal)
                    }
                }
            }
        }
    }
    
    func failedWithError(_ error: LocationError) {
        print(error)
    }
    
}

extension DetailViewController: UITableViewDelegate {}
