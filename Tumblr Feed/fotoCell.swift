//
//  fotoCell.swift
//  Tumblr Feed
//
//  Created by  Alex Sumak on 2/2/17.
//  Copyright © 2017  Alex Sumak. All rights reserved.
//

import UIKit

class fotoCell: UITableViewCell {

    @IBOutlet weak var foto: UIImageView!
    var imageUrl: URL?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

 
}
