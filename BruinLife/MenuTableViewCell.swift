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
//	var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light)))
	
	override func updateDisplay() {
		// do things to update the display for the new information
		backgroundImageView?.frame = bounds
		backgroundImageView?.clipsToBounds = true
		
		if collectionView?.frame == CGRectZero {
			collectionView?.frame = CGRect(origin: CGPointZero, size: frame.size)
		}
		collectionView?.reloadData()
		
		blurView.frame = bounds
//		vibrancyView.frame = (collectionView?.bounds)!
	}
	
	
	/// Preferred method for setting information and date, as this also changes the display
	override func changeInfo(info: RestaurantInfo, andDate date: NSDate, isHall: Bool) {
		self.information = info
		self.date = date
		self.isHall = isHall
		
		collectionView?.delegate = foodVC
		collectionView?.dataSource = foodVC
		
		var imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		
		backgroundImageView = UIImageView(image: UIImage(named: (information?.imageName(open()))!))
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		backgroundImageView = UIImageView(frame: CGRectZero)
		addSubview(backgroundImageView!)
		clipsToBounds = true
		
		collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: HorizontalFlow())
		collectionView?.registerClass(FoodCollectionViewCell.self, forCellWithReuseIdentifier: "foodDisplay") // is this right?
		collectionView?.registerClass(SectionCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerCell")
		collectionView?.backgroundView = blurView
		collectionView?.backgroundColor = .clearColor()
		collectionView?.alwaysBounceHorizontal = true
		collectionView?.alwaysBounceVertical = false
		
//		addSubview(blurView)
//		blurView.contentView.addSubview(vibrancyView)
//		vibrancyView.contentView.addSubview(collectionView!)
		addSubview(collectionView!)
    }
}
