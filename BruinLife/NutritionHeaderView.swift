//
//  NutritionHeaderView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 1/4/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

class NutritionHeaderView: UITableViewHeaderFooterView {
	private var mainLabel: UILabel
	private var sideLabel: UILabel
	private let headerGap: CGFloat = 8
	private var servingsCount: Int = 0
	
	private let darkGreyTextColor = UIColor(white: 0.3, alpha: 1.0)
	private let baseWidth: CGFloat = 280 * 0.9
	private let baseHeight: CGFloat = 460 * 0.5
	
	override init(frame: CGRect) {
		mainLabel = UILabel(frame: frame)
		sideLabel = UILabel(frame: frame)
		
		super.init(frame: frame)
		
		setup()
	}
	
	required init(coder aDecoder: NSCoder) {
		mainLabel = UILabel(coder: aDecoder)
		sideLabel = UILabel(coder: aDecoder)
		
		super.init(coder: aDecoder)
		
		setup()
	}
	
	override init(reuseIdentifier: String?) {
		mainLabel = UILabel()
		sideLabel = UILabel()
		
		super.init(reuseIdentifier: reuseIdentifier)
		
		setup()
	}
	
	func setup() {
		contentView.backgroundColor = .whiteColor()
		
		mainLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		mainLabel.text = "Nutrition Facts"
		mainLabel.font = .boldSystemFontOfSize(20)
		mainLabel.textAlignment = .Left
		mainLabel.sizeToFit()
		mainLabel.frame.origin = CGPoint(x: 8, y: headerGap)
		
		sideLabel.frame.size = CGSize(width: baseWidth, height: baseHeight)
		sideLabel.font = .italicSystemFontOfSize(12)
		sideLabel.textColor = darkGreyTextColor
		sideLabel.textAlignment = .Right
		
		setServingsCount(0)
		
		addSubview(sideLabel)
		addSubview(mainLabel)
	}
	
	func setServingsCount(count: Int) {
		servingsCount = count
		
		switch servingsCount {
		case 0:
			sideLabel.text = ""
		case 1:
			sideLabel.text = "for 1 serving"
		default:
			sideLabel.text = "for \(servingsCount) servings"
		}
		sideLabel.sizeToFit()
		sideLabel.frame.origin.x = frame.width - sideLabel.frame.width - 8
		sideLabel.frame.origin.y = mainLabel.frame.maxY - sideLabel.frame.height - 2 // dunno why it's not lined up right
		
		setNeedsDisplay()
	}
	
	
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
