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
	var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light)))
	
	override func updateDisplay() {
		// do things to update the display for the new information
		backgroundImageView?.frame = bounds
		backgroundImageView?.clipsToBounds = true
		
		if collectionView?.frame == CGRectZero {
			collectionView?.frame = CGRect(origin: CGPointZero, size: frame.size)
		}
		collectionView?.reloadData()
		
		blurView.frame = bounds
		vibrancyView.frame = (collectionView?.bounds)!
	}
	
	
	/// Preferred method for setting information and date, as this also changes the display
	override func changeInfo(info: RestaurantInfo, andDate date: NSDate, isHall: Bool) {
		self.information = info
		self.date = date
		self.isHall = isHall
		
//		collectionView?.delegate = foodVC
		collectionView?.dataSource = foodVC
//		collectionView?.contentSize = CGSize(width: bounds.width * 10, height: bounds.height)
		
		var imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		
		backgroundImageView = UIImageView(image: UIImage(named: (information?.imageName(open()))!))
		parallaxImageWithScrollPercent(0.0)
		backgroundImageView?.contentMode = .ScaleAspectFill
		
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
	
//	func updateInformation(info: RestaurantInfo) {
//		information = info
//		
//		if collectionView?.frame == CGRectZero {
//			collectionView?.frame = CGRect(origin: CGPointZero, size: frame.size)
//		}
//		collectionView?.reloadData() // because of the new information
//		
//		backgroundImageView?.removeFromSuperview()
//		backgroundImageView = UIImageView(image: UIImage(named: (information?.imageName(open()))!))
//		backgroundImageView?.frame = bounds
//		backgroundImageView?.clipsToBounds = true
//		backgroundImageView?.contentMode = .ScaleAspectFill
//		insertSubview(backgroundImageView!, belowSubview: blurView)
//		
//		blurView.frame = bounds
//		vibrancyView.frame = (collectionView?.bounds)!
//	}
	
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
	
//	func boundsForRow(row: Int) -> CGSize {
//		let width: CGFloat = 240.0
//		let numRows: Int = 3 // or 2
//		
////		let xZeroIndent: CGFloat = 16.0 // 16.0
//		let yIndent: CGFloat = 8.0 // or 10.0
////		let indexLatSpacing: CGFloat = xZeroIndent
//		let indexVertSpacing: CGFloat = yIndent
//		let height: CGFloat = (1.0 / CGFloat(numRows)) * (frame.height - (2.0 * yIndent) - (CGFloat(numRows - 1) * indexVertSpacing))
//		
////		let xVal = (xZeroIndent + CGFloat(row / numRows) * (indexLatSpacing + width))
////		let yMult = ((numRows == 0) ? 0.0 : CGFloat(row % numRows))
////		let yVal = (yMult * (indexVertSpacing + height)) + yIndent
//		
//		return CGSize(width: width, height: height)
//	}
}
