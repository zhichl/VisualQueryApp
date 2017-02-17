//
//  WindowHeatMapCellTableViewCell.swift
//  TestVQ
//
//  Created by Nebul on 24/11/2016.
//  Copyright © 2016 Roger Liu. All rights reserved.
//

import UIKit

class WindowHeatMapCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet var heatmapImageView: UIImageView!
    
}
