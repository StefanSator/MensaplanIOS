//
//  FavoritesTableViewCell.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealNameLabel: UILabel!
    @IBOutlet weak var mealPrizeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
