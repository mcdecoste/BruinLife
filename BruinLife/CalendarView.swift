//
//  CalendarView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/2/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class CalendarView: UIView {
	var monthTitle: UILabel
	var dayTitle: UILabel
	
	let monthRatio: CGFloat = 0.5
	let dayRatio: CGFloat = 0.8
	
	override init(frame: CGRect) {
		monthTitle = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height * monthRatio)))
		monthTitle.textColor = .redColor()
		monthTitle.textAlignment = .Center
		monthTitle.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
		
		var dayHeight = frame.height * dayRatio
		dayTitle = UILabel(frame: CGRect(x: frame.minX, y: frame.maxY - dayHeight, width: frame.width, height: dayHeight))
		dayTitle.textAlignment = .Center
//		dayTitle.font = UIFont.systemFontOfSize(UIFont.systemFontSize() + 12)
		dayTitle.font = UIFont(name: "HelveticaNeue-Thin", size: UIFont.systemFontSize() + 12)
		
		super.init(frame: frame)
		
		addSubview(monthTitle)
		addSubview(dayTitle)
	}
	
	required init(coder aDecoder: NSCoder) {
		var frame = CGRectZero
		
		monthTitle = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height * monthRatio)))
		monthTitle.textColor = .redColor()
		
		dayTitle = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: frame.height * dayRatio)))
		
		super.init(coder: aDecoder)
		
		addSubview(monthTitle)
		addSubview(dayTitle)
	}
}
