//
//  ReviewTableViewCell.swift
//  hw9
//
//  Created by Xinyi Shen on 4/17/18.
//  Copyright © 2018 Xinyi. All rights reserved.
//

import UIKit
import Cosmos

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet weak var review: UITextView!
    @IBOutlet weak var star: CosmosView!
    @IBOutlet weak var reviewDate: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
