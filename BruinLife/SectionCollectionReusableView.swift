//
//  SectionCollectionReusableView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/30/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class SectionCollectionReusableView: UICollectionReusableView {
	var title: UILabel = UILabel(frame: CGRectZero)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		title.font = .systemFontOfSize(18)
		title.textColor = UIColor(white: 0.0, alpha: 0.7)
		addSubview(title)
//		backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.4)
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
	func setTitle(name: String) {
		title.text = name
		title.sizeToFit()
		
		let topIndex: CGFloat = 4.0
		var titleSize = title.frame.size
		frame.size = CGSize(width: titleSize.width, height: titleSize.height + topIndex)
		title.frame.origin = CGPoint(x: 0.0, y: topIndex)
	}
}
