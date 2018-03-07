//
//  ColoredTextLabel.swift
//  Diary App
//
//  Created by Max Ramirez on 2/20/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit

// Extension that changes color of the number of characters in the charactersCount label.

extension UILabel {
    
    func colorString(text: String?, coloredText: String?, color: UIColor? = UIColor(red: 125.0/255.0, green: 157.0/255.0, blue: 91.0/255.0, alpha: 1.0)) {
        
        let attributedString = NSMutableAttributedString(string: text!)
        let range = (text! as NSString).range(of: coloredText!)
        attributedString.setAttributes([NSAttributedStringKey.foregroundColor: color!],
                                       range: range)
        self.attributedText = attributedString
    }
}
