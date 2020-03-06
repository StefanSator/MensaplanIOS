//
//  FavoritesTableViewCell.swift
//  Mensaplan
//
//  Created by Stefan Sator on 10.11.19.
//  Copyright © 2019 Stefan Sator. All rights reserved.
//

import UIKit

/// Class representing a cell item in the FavoritesTableView.
class FavoritesTableViewCell: UITableViewCell {
    /// Label containing the name of the meal item.
    @IBOutlet weak var mealNameLabel: UILabel!
    /// Label containing the kind of like. It displays if user has liked or disliked the meal item.
    @IBOutlet weak var kindLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
