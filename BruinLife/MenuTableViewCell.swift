//
//  MenuTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/4/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class MenuTableViewCell: FoodTableViewCell {
	var collectionView: UICollectionView?
	var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
	
	override func finishSetup() {
		// add the labels!
		super.finishSetup()
		
		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: HorizontalFlow())
		collectionView?.registerClass(FoodCollectionViewCell.self, forCellWithReuseIdentifier: "foodDisplay")
		collectionView?.registerClass(SectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell")
		collectionView?.backgroundView = blurView
		collectionView?.backgroundColor = .clearColor()
		collectionView?.alwaysBounceHorizontal = true
		collectionView?.alwaysBounceVertical = false
		
		addSubview(collectionView!)
	}
	
	override func updateDisplay() {
		// do things to update the display for the new brief
		backgroundImageView?.frame = bounds
		backgroundImageView?.clipsToBounds = true
		
		if collectionView?.frame == CGRectZero {
			collectionView?.frame = CGRect(origin: CGPointZero, size: frame.size)
		}
		collectionView?.reloadData()
		
		blurView.frame = bounds
	}
	
	/// Preferred method for setting brief and date, as this also changes the display
	override func changeInfo(info: RestaurantBrief, andDate date: NSDate, isHall: Bool) {
		self.brief = info
		self.date = date
		self.isHall = isHall
		
		let imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		backgroundImageView = UIImageView(image: ImageProvider.sharedInstance.image(brief!.hall, open: open))
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
}
