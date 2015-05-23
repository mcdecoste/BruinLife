//
//  ImageModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/12/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

private let _ImageProviderSharedInstance = ImageProvider()

/// Convert the image to grayscale! Now maintains retina qualities.
private func grayscale(image: UIImage) -> UIImage {
	let scale = UIScreen.mainScreen().scale
	let imageRect = CGRect(origin: CGPointZero, size: CGSize(width: image.size.width * scale, height: image.size.height * scale))
	
	var context = CGBitmapContextCreate(nil, Int(imageRect.width), Int(imageRect.height), 8, 0, CGColorSpaceCreateDeviceGray(), CGBitmapInfo(CGImageAlphaInfo.None.rawValue))
	CGContextDrawImage(context, imageRect, image.CGImage)
	
	return UIImage(CGImage: CGBitmapContextCreateImage(context), scale: scale, orientation: image.imageOrientation)!
}

class ImageProvider {
	class var sharedInstance: ImageProvider {
		get {
			return _ImageProviderSharedInstance
		}
	}
	
	private let deNeve: UIImage = UIImage(named: "De Neve")!
	private let covel: UIImage = UIImage(named: "Covel")!
	private let hedrick: UIImage = UIImage(named: "Hedrick")!
	private let feast: UIImage = UIImage(named: "Feast")!
	private let rendez: UIImage = UIImage(named: "Rendezvous")!
	private let bPlate: UIImage = UIImage(named: "Bruin Plate")!
	private let bCafe: UIImage = UIImage(named: "Bruin Cafe")!
	private let cafe1919: UIImage = UIImage(named: "Cafe 1919")!
	
	private let deNeveDark: UIImage
	private let covelDark: UIImage
	private let hedrickDark: UIImage
	private let feastDark: UIImage
	private let rendezDark: UIImage
	private let bPlateDark: UIImage
	private let bCafeDark: UIImage
	private let cafe1919Dark: UIImage
	
	init() {
		deNeveDark = grayscale(deNeve)
		covelDark = grayscale(covel)
		hedrickDark = grayscale(hedrick)
		feastDark = grayscale(feast)
		rendezDark = grayscale(rendez)
		bPlateDark = grayscale(bPlate)
		bCafeDark = grayscale(bCafe)
		cafe1919Dark = grayscale(cafe1919)
	}
	
	func image(hall: Halls, open: Bool) -> UIImage {
		switch hall {
		case .DeNeve:
			return open ? deNeve : deNeveDark
		case .Covel:
			return open ? covel : covelDark
		case .Hedrick:
			return open ? hedrick : hedrickDark
		case .Feast:
			return open ? feast : feastDark
		case .BruinPlate:
			return open ? bPlate : bPlateDark
		case .Cafe1919:
			return open ? cafe1919 : cafe1919Dark
		case .Rendezvous:
			return open ? rendez : rendezDark
		case .BruinCafe:
			return open ? bCafe : bCafeDark
		default:
			return UIImage(named: "AppIcon")!
		}
	}
}