//
//  MealTableViewCell.swift
//  Mensaplan
//
//  Created by Stefan Sator on 11.09.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCards

class MealTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var card: MDCCard!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealPrizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        card.isSelected = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

}
