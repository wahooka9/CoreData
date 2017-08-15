//
//  CardCell.swift
//  CoreDataExampleSwift
//
//  Created by Andrew Riznyk on 7/30/17.
//  Copyright © 2017 Andrew Riznyk. All rights reserved.
//

import UIKit

class CardCell: UITableViewCell {

    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardType: UILabel!
    @IBOutlet weak var deckID: UILabel!
    @IBOutlet weak var randomStringLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
