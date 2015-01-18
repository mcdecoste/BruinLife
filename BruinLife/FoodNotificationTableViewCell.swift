//
//  FoodNotificationTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/8/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodNotificationTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
}
