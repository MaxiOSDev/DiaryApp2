//
//  ComposeEntryCell.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit

class ComposeEntryCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        setDateLabel()
    }
    
    // Helper methods
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
        dateLabel.text = dateString
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
    
}

