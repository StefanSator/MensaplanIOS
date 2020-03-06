//
//  RoundedButton.swift
//  Mensaplan
//
//  Created by Stefan Sator on 13.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit


/// Class which defines a Custom Button
@IBDesignable class RoundedButton: UIButton {
    
    /// Corner Radius of the button.
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            updateCorners(value: cornerRadius)
        }
    }
    
    /// Background color of the button.
    @IBInspectable var customBackgroundColor: UIColor = UIColor.red {
        didSet {
            updateColor(color: customBackgroundColor)
        }
    }
    
    /// Text color of the button.
    @IBInspectable var customTextColor: UIColor = UIColor.white {
        didSet {
            updateTextColor(color: customTextColor)
        }
    }
    
    /// Initialize a Rounded Button from Code.
    ///
    /// - Parameter frame: The frame to create the button.
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    /// Initialize a Rounded Button from Storyboard.
    ///
    /// - Parameter aDecoder: Attribute Set to create Button from.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    /// Called when a Designable is created in Interface Builder.
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    
    /// Shared Initializer which is called by all constructors for shared initialization of the Custom Button.
    func sharedInit() {
        updateCorners(value: cornerRadius)
        updateColor(color: customBackgroundColor)
        updateTextColor(color: customTextColor)
    }
    
    /// Update Text Color of Button.
    ///
    /// - Parameter color: New Text color.
    func updateTextColor(color: UIColor) {
        setTitleColor(color, for: .normal)
    }
    
    /// Update Background Color of Button.
    ///
    /// - Parameter color: New Background color.
    func updateColor(color: UIColor) {
        let image = createImage(color: color)
        setBackgroundImage(image, for: .normal)
        self.clipsToBounds = true // needs to be set, otherwise corners not rounded
    }
    
    /// Update Corner Radius.
    ///
    /// - Parameter value: New corner radius.
    func updateCorners(value: CGFloat) {
        self.layer.cornerRadius = value
    }
    
    /// Creates UIButton Fade Animation
    ///
    /// - Parameter color: UIColor Object to be painted in
    /// - Returns: UIImage
    func createImage(color: UIColor) -> UIImage {
        // Create a blank 1x1px image
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0.0)
        // Set a color to be painted in
        color.setFill()
        // Draw a rectangle with the fill color
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        // Set background image of the button to the image we created
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }

}
