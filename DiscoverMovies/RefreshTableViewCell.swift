//
//  RefreshTableViewCell.swift
//  DiscoverMovies
//
//  Created by Qingfeng Liu on 2020-01-25.
//  Copyright © 2020 Qingfeng Liu. All rights reserved.
//

import UIKit

class RefreshTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        activityIndicator.color = .gray
    }
    
}
