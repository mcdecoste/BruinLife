//
//  DayDisplayTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/11/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class DayDisplayTableViewCell: UITableViewCell {
	var day: Int = 0 {
		didSet {
			textLabel?.text = DayDisplay.titleString(day)
		}
	}
}