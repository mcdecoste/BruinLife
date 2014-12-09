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
	
	override func updateDisplay() {
		scrollView?.setFoods((information?.foods)!, vc: foodVC!, newFrame: frame)
	}
	
	func updateInformation(info: RestaurantInfo, controller: FoodTableViewController) {
		information = info
		foodVC = controller
		scrollView?.foodVC = foodVC
		scrollView?.setFoods((information?.foods)!)
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		scrollView = FoodsScrollView(frame: CGRectZero)
		addSubview(scrollView!)
    }
	
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
