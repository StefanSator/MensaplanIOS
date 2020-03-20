//
//  MealTableViewCell.swift
//  Mensaplan
//

import UIKit
import MaterialComponents.MaterialCards

/// Class representing a cell item in the MealTableView.
class MealTableViewCell: UITableViewCell {
    //MARK: Properties
    /// The Material Design Card wrapping the information of the cell item.
    @IBOutlet weak var card: MDCCard!
    /// The image displaying the category of the meal.
    @IBOutlet weak var mealImage: UIImageView!
    /// The Label containing the name of the meal item.
    @IBOutlet weak var mealNameLabel: UILabel!
    /// The Label containing the number of likes of the meal item.
    @IBOutlet weak var likeNumberLabel: UILabel!
    /// The Label containing the number of dislikes of the meal item.
    @IBOutlet weak var dislikeNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        card.isSelected = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }

}
