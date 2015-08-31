//
//  MainTableViewCell.swift
//  Simplistic
//
//  Created by Arnaud Thiercelin on 6/26/15.
//  Copyright © 2015 Arnaud Thiercelin. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

	@IBOutlet var itemLabel: UILabel!
	@IBOutlet var itemField: UITextField!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
