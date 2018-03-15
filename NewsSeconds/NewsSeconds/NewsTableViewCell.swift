//
//  NewsTableViewCell.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 15/03/18.
//  Copyright © 2018 Ananth. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rssTitle: UILabel!
    @IBOutlet weak var rssDescription: UITextView!
    @IBOutlet weak var rssImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
