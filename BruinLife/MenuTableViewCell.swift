//
//  MenuTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/4/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class MenuTableViewCell: FoodTableViewCell {
	var scrollView: FoodsScrollView?
	
	var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
	var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light)))
	
	override func updateDisplay() {
		scrollView?.setFoods(allFoodsForSections((information?.sections)!), vc: foodVC!, newFrame: frame)
	}
	
	func allFoodsForSections(sections: Array<SectionInfo>) -> Array<MainFoodInfo> {
		var allFoods: Array<MainFoodInfo> = []
		
		for section in sections {
			for mainFood in section.foods {
				allFoods.append(mainFood)
			}
		}
		return allFoods
	}
	
	func updateInformation(info: RestaurantInfo, controller: FoodTableViewController) {
		information = info
		foodVC = controller
		scrollView?.foodVC = foodVC
		scrollView?.setFoods(allFoodsForSections((information?.sections)!))
		
		backgroundImageView?.removeFromSuperview()
		
		backgroundImageView = UIImageView(image: UIImage(named: (information?.imageName(open()))!))
		backgroundImageView?.frame = bounds
		backgroundImageView?.clipsToBounds = true
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, belowSubview: blurView)
		
		blurView.frame = bounds
		vibrancyView.frame = (scrollView?.bounds)!
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		scrollView = FoodsScrollView(frame: CGRectZero)
		addSubview(blurView)
		blurView.contentView.addSubview(vibrancyView)
		vibrancyView.contentView.addSubview(scrollView!)
    }
	
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
