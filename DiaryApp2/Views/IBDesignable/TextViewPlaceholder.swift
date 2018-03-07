//
//  TextViewPlaceholder.swift
//  Diary App
//
//  Created by Max Ramirez on 2/19/18.
//  Copyright © 2018 Max Ramirez. All rights reserved.
//

import UIKit

// Let's just say when using Interface Builder, I love IBDesignable
// code from here -> https://stackoverflow.com/questions/1328638/placeholder-in-uitextview?rq=1

@IBDesignable
class UIPlaceHolderTextView: UITextView {
    
    @IBInspectable var placeholder: String = ""
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray
    
    private let uiPlaceholderTextChangedAnimationDuration: Double = 0.05
    private let defaultTagValue = 999
    
    private var placeHolderLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: NSNotification.Name.UITextViewTextDidChange,
            object: nil
        )
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        // Font part is for the lined text view
        // start
        let font = self.font
        self.font = nil
        self.font = font
        // end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: NSNotification.Name.UITextViewTextDidChange,
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textChanged),
            name: NSNotification.Name.UITextViewTextDidChange,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UITextViewTextDidChange,
            object: nil
        )
    }
    
    @objc private func textChanged() {
        guard !placeholder.isEmpty else {
            return
        }
        UIView.animate(withDuration: uiPlaceholderTextChangedAnimationDuration) {
            if self.text.isEmpty {
                self.viewWithTag(self.defaultTagValue)?.alpha = CGFloat(1.0)
            }
            else {
                self.viewWithTag(self.defaultTagValue)?.alpha = CGFloat(0.0)
            }
        }
    }
    
    override var text: String! {
        didSet{
            super.text = text
            textChanged()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        // MARK: - Placeholder text
        if !placeholder.isEmpty {
            if placeHolderLabel == nil {
                placeHolderLabel = UILabel.init(frame: CGRect(x: 0, y: 8, width: bounds.size.width - 16, height: 0))
                placeHolderLabel!.lineBreakMode = .byWordWrapping
                placeHolderLabel!.numberOfLines = 0
                placeHolderLabel!.font = font
                placeHolderLabel!.backgroundColor = UIColor.clear
                placeHolderLabel!.textColor = placeholderColor
                placeHolderLabel!.alpha = 0
                placeHolderLabel!.tag = defaultTagValue
                self.addSubview(placeHolderLabel!)
            }
            
            placeHolderLabel!.text = placeholder
            placeHolderLabel!.sizeToFit()
            self.sendSubview(toBack: placeHolderLabel!)
            
            if text.isEmpty && !placeholder.isEmpty {
                viewWithTag(defaultTagValue)?.alpha = 1.0
            }
        }
        
        // MARK: - Text View Lined! Translated some objective-c code to swift! Here it is -> https://github.com/danielamitay/DALinedTextView/blob/master/DALinedTextView/DALinedTextView.m
        // start
        let screen = self.window?.screen ?? .main
        let lineWidth: CGFloat = 1.0 / screen.scale
        let context = UIGraphicsGetCurrentContext()
        
        if let context = context {
            context.setLineWidth(lineWidth)
            context.beginPath()
            context.setStrokeColor(self.placeholderColor.cgColor)
            if let fontDescender = self.font?.descender {
                let baseOffset = self.textContainerInset.top + fontDescender
                let screenScale = UIScreen.main.scale
                let boundsX = self.bounds.origin.x
                let boundsWidth = self.bounds.size.width
                
                let firstVisbleLine = max(1, (self.contentOffset.y / self.font!.lineHeight))
                let lastVisibleLine = ceil((self.contentOffset.y + self.bounds.size.height) / self.font!.lineHeight)
                var line = firstVisbleLine
                while line <= lastVisibleLine {
                    line += 1
                    let linePointY = (baseOffset + (self.font!.lineHeight * line))
                    let roundedLinePointY = round(linePointY * screenScale) / screenScale
                    let point = CGPoint.init(x: boundsX, y: roundedLinePointY)
                    let anotherPoint = CGPoint.init(x: boundsWidth, y: roundedLinePointY)
                    context.move(to: point)
                    context.addLine(to: anotherPoint)
                }
                
                context.closePath()
                context.strokePath()
            }
            
        }
        
        super.draw(rect)
    }
    
    func setFont(_ font: UIFont) {
        self.setFont(font)
        self.setNeedsDisplay()
    }
    
    func setTextContainerInset(_ textContainerInset: UIEdgeInsets) {
        self.setTextContainerInset(textContainerInset)
        self.setNeedsDisplay()
    }
    
    func setHorizontalLineColor(_ horizontalLineColor: UIColor) {
        self.setNeedsDisplay()
    }
    // end
}
