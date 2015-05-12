//
//  ImageModel.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 5/12/15.
//  Copyright (c) 2015 Matthew DeCoste. All rights reserved.
//

import UIKit

private let _ImageProviderSharedInstance = ImageProvider()

class ImageProvider {
	class var sharedInstance: ImageProvider {
		get {
			return _ImageProviderSharedInstance
		}
	}
	
	private lazy var deNeve: UIImage = { return UIImage(named: "De Neve")! }()
	private lazy var covel: UIImage = { return UIImage(named: "Covel")! }()
	private lazy var hedrick: UIImage = { return UIImage(named: "Hedrick")! }()
	private lazy var feast: UIImage = { return UIImage(named: "Feast")! }()
	private lazy var rendez: UIImage = { return UIImage(named: "Rendezvous")! }()
	private lazy var bPlate: UIImage = { return UIImage(named: "Bruin Plate")! }()
	private lazy var bCafe: UIImage = { return UIImage(named: "Bruin Cafe")! }()
	private lazy var cafe1919: UIImage = { return UIImage(named: "Cafe 1919")! }()
	
	init() {
		
	}
	
	private func grayscale(image: UIImage) -> UIImage {
		let imageRect = CGRect(origin: CGPointZero, size: image.size)
		let bitMapInfo = CGBitmapInfo(CGImageAlphaInfo.None.rawValue)
		var context = CGBitmapContextCreate(nil, Int(image.size.width), Int(image.size.height), 8, 0, CGColorSpaceCreateDeviceGray(), bitMapInfo)
		
		CGContextDrawImage(context, imageRect, image.CGImage)
		return UIImage(CGImage: CGBitmapContextCreateImage(context))!
	}
	
	func image(hall: Halls, open: Bool) -> UIImage {
		var image: UIImage
		switch hall {
		case .DeNeve:
			image = deNeve
		case .Covel:
			image = covel
		case .Hedrick:
			image = hedrick
		case .Feast:
			image = feast
		case .BruinPlate:
			image = bPlate
		case .Cafe1919:
			image = cafe1919
		case .Rendezvous:
			image = rendez
		case .BruinCafe:
			image = bCafe
		default:
			image = UIImage(named: "AppIcon")!
		}
		return open ? image : grayscale(image)
	}
}

/*

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
  // Create image rectangle with current image width/height
  CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
 
  // Grayscale color space
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
 
  // Create bitmap content with current image size and grayscale colorspace
  CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
 
  // Draw image into current context, with specified rectangle
  // using previously defined context (with grayscale colorspace)
  CGContextDrawImage(context, imageRect, [image CGImage]);
 
  // Create bitmap image info from pixel data in current context
  CGImageRef imageRef = CGBitmapContextCreateImage(context);
 
  // Create a new UIImage object  
  UIImage *newImage = [UIImage imageWithCGImage:imageRef];
 
  // Release colorspace, context and bitmap information
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  CFRelease(imageRef);
 
  // Return the new grayscale image
  return newImage;
}

- (UIImage *) convertToGreyscale:(UIImage *)i {

    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;

    int colors = kGreen | kBlue | kRed;
    int m_width = i.size.width;
    int m_height = i.size.height;

    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [i CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);

    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);

    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4]=0;
        int val=m_imageData[i];
        result[i*4+1]=val;
        result[i*4+2]=val;
        result[i*4+3]=val;
    }

    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);

    free(m_imageData);

    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];

    return resultUIImage;
}
*/