//
//  FoodTableViewCell.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/8/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
	var information: RestaurantInfo?
	var date: NSDate?
	var foodVC: FoodTableViewController?
	var backgroundImageView: UIImageView?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		backgroundImageView = UIImageView(frame: CGRectZero)
		addSubview(backgroundImageView!)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	/// Preferred method for setting information and date, as this also changes the display
	func changeInfo(info: RestaurantInfo, andDate newDate: NSDate) {
		information = info
		date = newDate
		
		var imageIndex = (subviews as NSArray).indexOfObject(backgroundImageView!)
		
		backgroundImageView?.removeFromSuperview()
		
//		var modImage = darkerImage(info.image)

//		information?.shortImage = UIImageEffects.imageByDarkeningImage(information?.shortImage)
//		information?.tallImage = UIImageEffects.imageByDarkeningImage(information?.tallImage)
//		backgroundImageView = UIImageView(image: (bounds.height > CGFloat(100)) ? information?.tallImage : information?.shortImage)
		backgroundImageView = UIImageView(image: information?.tallImage)
		backgroundImageView?.frame = bounds
		backgroundImageView?.clipsToBounds = true
		backgroundImageView?.contentMode = .ScaleAspectFill
//		backgroundImageView?.contentMode = UIViewContentMode.Bottom
		
//		addSubview(backgroundImageView!)
//		insertSubview(backgroundImageView!, belowSubview: blurView)
		insertSubview(backgroundImageView!, atIndex: imageIndex)
		
		updateDisplay()
	}
	
	func updateDisplay() {}
	
	//	func lowerSaturation(onImage image: UIImage?) -> UIImage? {
	//		let saturationFactor = 0.75
	//
	//		var context = CIContext(options: nil)
	//		var ciImage = CIImage(CGImage: image?.CGImage)
	//		var filter = CIFilter(name: "CIColorControls")
	//
	//		filter.setValue(ciImage, forKey: kCIInputImageKey)
	//		filter.setValue(saturationFactor, forKey: kCIInputImageKey)
	//
	//		var result = filter.valueForKey(kCIOutputImageKey) as CIImage
	//		var cgImage = context.createCGImage(result, fromRect: result.extent())
	//		var image = UIImage(CGImage: cgImage)
	//		return image!
	//	}
	
	func darkerImage(image: UIImage?) -> UIImage? {
		let darknessAlpha: CGFloat = 0.5
		
		var inputImage = CIImage(image: image)
		var context = CIContext(options: nil)
		
		// create darkness
		var blackGenerator = CIFilter(name: "CIConstantColorGenerator")
		var black = CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: darknessAlpha)
		blackGenerator.setValue(black, forKeyPath: "inputColor")
		var blackImage = blackGenerator.outputImage
		
		// use darkness
		var compositeFilter = CIFilter(name: "CIMultiplyBlendMode")
		compositeFilter.setValue(blackImage, forKeyPath: "inputImage")
		compositeFilter.setValue(inputImage, forKeyPath: "inputBackgroundImage")
		var darkenedImage = compositeFilter.outputImage
		
		return UIImage(CGImage: context.createCGImage(darkenedImage, fromRect: inputImage.extent()))
	}
}
