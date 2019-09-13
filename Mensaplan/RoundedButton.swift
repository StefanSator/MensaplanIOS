//
//  RoundedButton.swift
//  Mensaplan
//
//  Created by Stefan Sator on 13.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit


@IBDesignable class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 15 {
        didSet {
            updateCorners(value: cornerRadius)
        }
    }
    
    @IBInspectable var customBackgroundColor: UIColor = UIColor.red {
        didSet {
            updateColor(color: customBackgroundColor)
        }
    }
    
    @IBInspectable var customTextColor: UIColor = UIColor.white {
        didSet {
            updateTextColor(color: customTextColor)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        updateCorners(value: cornerRadius)
        updateColor(color: customBackgroundColor)
        updateTextColor(color: customTextColor)
    }
    
    func updateTextColor(color: UIColor) {
        setTitleColor(color, for: .normal)
    }
    
    func updateColor(color: UIColor) {
        let image = createImage(color: color)
        setBackgroundImage(image, for: .normal)
        self.clipsToBounds = true // needs to be set, otherwise corners not rounded
    }
    
    func updateCorners(value: CGFloat) {
        self.layer.cornerRadius = value
    }
    
    /* Copys Apple's System UIButton Fade Animation */
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
