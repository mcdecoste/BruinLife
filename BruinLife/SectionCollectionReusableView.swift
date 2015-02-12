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
		title.textColor = UIColor(white: 1.0, alpha: 0.7)
		addSubview(title)
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
	func changeTitle(name: String) {
		title.text = name
		title.sizeToFit()
		
		let topIndex: CGFloat = 4.0
		var titleSize = title.frame.size
		frame.size = CGSize(width: titleSize.width, height: titleSize.height + topIndex)
		title.frame.origin = CGPoint(x: 0.0, y: topIndex)
	}
}
