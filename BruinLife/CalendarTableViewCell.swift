//
//  CalendarTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/2/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {
	let calHeight: CGFloat = 66.0
	let calWidth: CGFloat = 48.0
	let calX: CGFloat = 8.0
	let calTextSpacing: CGFloat = 16.0
	
	let dowFormat = "EEEE"
	let monthFormat = "MMM."
	let dayFormat = "d"
	
	var calView: CalendarView?
	var dowLabel = UILabel()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		calView = CalendarView(frame: CGRect(x: calX, y: 0.0, width: calWidth, height: calHeight))
		let labelX = calX + calWidth + calTextSpacing
		
		dowLabel.frame = CGRect(x: labelX, y: 0.0, width: 200.0 - labelX, height: 66.0)
		dowLabel.textAlignment = .Left
		
		addSubview(calView!)
		addSubview(dowLabel)
    }
	
	func setDate(date: NSDate) {
		var formatter = NSDateFormatter()
		formatter.dateFormat = dowFormat
		dowLabel.text = formatter.stringFromDate(date)
		
		formatter.dateFormat = monthFormat
		calView?.monthTitle.text = formatter.stringFromDate(date)
		
		formatter.dateFormat = dayFormat
		calView?.dayTitle.text = formatter.stringFromDate(date)
	}
}
