//
//  ScrollSelectionTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/16/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class ScrollSelectionTableViewCell: UITableViewCell {
	var clipView = ScrollSelectionView()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		addSubview(clipView)
    }
	
	func setEntries(entries: Array<String>) {
		clipView.changeEntries(entries)
	}
	
	override func layoutSubviews() {
		clipView.frame = bounds
		clipView.layoutSubviews()
	}
}
