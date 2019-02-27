//
//  TableViewCell.swift
//  SQLiteSample
//
//  Created by Seonghun Kim on 27/02/2019.
//  Copyright © 2019 Seonghun Kim. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var stringLabel: UILabel!
    @IBOutlet weak var intLabel: UILabel!
    @IBOutlet weak var boolLabel: UILabel!
    @IBOutlet weak var doubleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
