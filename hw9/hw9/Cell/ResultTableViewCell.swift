//
//  ResultTableViewCell.swift
//  hw9
//
//  Created by Xinyi Shen on 4/12/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var favorite: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
