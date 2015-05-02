//
//  ScrollSelectionView.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/16/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class ScrollSelectionView: UIView {
	var scrollView = UIScrollView()
	var entries: Array<String> = [] {
		didSet {
			labels = []
			
			for (index, entry) in enumerate(entries) {
				var label = UILabel()
				label.font = .systemFontOfSize(24)
				label.text = entry
				label.sizeToFit()
				label.textAlignment = .Center
				labels.append(label)
			}
		}
	}
	var labels = [UILabel]()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		scrollView.frame = frame
		scrollViewSetup()
	}
	
	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		scrollViewSetup()
	}
	
	func scrollViewSetup() {
		scrollView.backgroundColor = .clearColor()
		
		scrollView.pagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.scrollEnabled = true
		scrollView.clipsToBounds = false
		addSubview(scrollView)
	}
	
	func scrollToPage(page: Int) {
		scrollView.setContentOffset(CGPoint(x: scrollView.bounds.width * CGFloat(page), y: 0), animated: true)
	}
	
	override func layoutSubviews() {
		for label in labels {
			label.removeFromSuperview()
		}
		
		scrollView.frame = CGRect(origin: CGPointZero, size: CGSize(width: 136.0 + bounds.width * 0.2, height: bounds.height))
		scrollView.center = center
		scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(entries.count), height: bounds.height)
		scrollView.contentOffset = CGPointZero
		
		for (index, label) in enumerate(labels) {
			let xVal = ((scrollView.frame.width * (CGFloat(index) + 0.5)))
			label.center = CGPoint(x: xVal, y: scrollView.center.y)
			
			scrollView.addSubview(label)
		}
	}
	
	override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
		return pointInside(point, withEvent: event) ? scrollView : nil
	}
}
