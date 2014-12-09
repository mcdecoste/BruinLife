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
		scrollView?.setFoods((information?.foods)!, vc: foodVC!, newFrame: frame)
	}
	
	func updateInformation(info: RestaurantInfo, controller: FoodTableViewController) {
		information = info
		foodVC = controller
		scrollView?.foodVC = foodVC
		scrollView?.setFoods((information?.foods)!)
		
		backgroundImageView?.removeFromSuperview()
		
		backgroundImageView = UIImageView(image: info.image)
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
//		blurView.contentView.addSubview(scrollView!)
    }
	
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
