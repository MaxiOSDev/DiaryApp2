//
//  DiaryEntryCell.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit

class DiaryEntryCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    // First View
    @IBOutlet weak var entryImage: UIImageViewX!
    @IBOutlet weak var statusImage: UIImageView!
    
    // Second View
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var entryTextLabel: UILabel!
    
    // Third View
    @IBOutlet weak var geolocateIcon: UIImageView!
    @IBOutlet weak var addLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}

