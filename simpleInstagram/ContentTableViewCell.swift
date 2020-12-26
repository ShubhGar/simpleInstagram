//
//  ContentTableViewCell.swift
//  simpleInstagram
//
//  Created by shubham Garg on 28/07/20.
//  Copyright © 2020 shubham Garg. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var contentimageView: UIImageView!
    @IBOutlet weak var captionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
