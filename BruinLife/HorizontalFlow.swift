//
//  HorizontalFlow.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/29/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class HorizontalFlow: UICollectionViewFlowLayout {
	var headerWidths = [CGFloat]()
	private var collectionContentSize: CGSize = CGSizeZero
	private let rowsPerCol: CGFloat = 3
	
	override init() {
		super.init()
		setupHelper()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		setupHelper()
	}
	
	override func prepareLayout() {
		let numSections = collectionView!.numberOfSections()
		var sectionCount = [Int]()
		for section in 0 ..< numSections {
			sectionCount.append(collectionView!.numberOfItemsInSection(section))
		}
		
		var width: CGFloat = 0
		for section in 0 ..< numSections {
			var numCol = ceil(CGFloat(sectionCount[section]) / rowsPerCol)
			width += numCol * itemSize.width + sectionInset.left + sectionInset.right
			width += numCol * minimumLineSpacing
		}
		
		collectionContentSize = CGSize(width: width, height: 220)
	}
	
	override func collectionViewContentSize() -> CGSize {
		return collectionContentSize
	}
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
		var answer = super.layoutAttributesForElementsInRect(rect)! as! Array<UICollectionViewLayoutAttributes>
		var sectNoSupp: Array<Int> = []
		
		// count the section headers
		for layout in answer {
			if find(sectNoSupp, layout.indexPath.section) == nil {
				sectNoSupp.append(layout.indexPath.section)
			}
		}
		
		for layout in answer {
			if layout.representedElementCategory == .SupplementaryView {
				sectNoSupp.removeAtIndex(find(sectNoSupp, layout.indexPath.section)!)
			}
		}
		
		for section in sectNoSupp {
			answer.append(self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: section)))
		}
		
		for layout in answer {
			if layout.representedElementKind != nil && layout.representedElementKind == UICollectionElementKindSectionHeader {
				layout.frame = frameForHeaderLayout(layout)
			}
		}
		
		return answer
	}
	
	override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
		var layout: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
		layout.frame = frameForHeaderLayout(layout)
		return layout
	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		return true
	}
	
	// MARK: Helpers
	func setupHelper() {
		scrollDirection = .Horizontal
		headerReferenceSize = CGSize(width: 10, height: 26)
		itemSize = CGSize(width: 200, height: 60)
		minimumInteritemSpacing = 4
		minimumLineSpacing = 10 // not super set clean yet
		sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 10)
	}
	
	func frameForHeaderLayout(layout: UICollectionViewLayoutAttributes) -> CGRect {
		let indexPath = layout.indexPath
		let itemIndex = max(0, collectionView!.numberOfItemsInSection(indexPath.section) - 1)
		
		let firstAttr = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: indexPath.section))
		let lastAttr = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: itemIndex, inSection: indexPath.section))
		
		let width = headerWidths.count - 1 >= indexPath.section ? headerWidths[indexPath.section] : 240
		let x = min(max(collectionView!.contentOffset.x + 4, firstAttr.frame.minX), lastAttr.frame.maxX - width)
		
		return CGRect(x: x, y: layout.frame.minY, width: width, height: layout.frame.height)
	}
}

class VerticalFlow: UICollectionViewFlowLayout {
	private var wideEnough: Bool {
		if let coll = collectionView {
			return coll.bounds.width > 320
		}
		return true
	}
	private var columnsPerRow: Int {
		return wideEnough ? 2 : 1
	}
	private var heightPerRow: CGFloat {
		return wideEnough ? 60 : 60 // 90 : 60
	}
	
	override init() {
		super.init()
		setupHelper()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupHelper()
	}
	
	override func collectionViewContentSize() -> CGSize {
		let numSections = collectionView!.numberOfSections()
		var sectionCount = [Int]()
		for section in 0 ..< numSections {
			sectionCount.append(collectionView!.numberOfItemsInSection(section))
		}
		
		var height: CGFloat = 0
		for section in 0 ..< numSections {
			var numRows = ceil(CGFloat(sectionCount[section]) / CGFloat(columnsPerRow))
			height += numRows * (itemSize.height + minimumLineSpacing) + sectionInset.top + sectionInset.bottom - minimumLineSpacing + headerReferenceSize.height
		}
		
		return CGSize(width: collectionView!.bounds.width, height: height)
	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		return true
	}
	
	// MARK: Helpers
	func setupHelper() {
		headerReferenceSize = CGSize(width: 10, height: 26)
		itemSize = CGSize(width: 150, height: heightPerRow)
		minimumInteritemSpacing = 4
		minimumLineSpacing = 10 // not super set clean yet
		sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 16, right: 2)
	}
	
	func updateForCollectionSize() {
		let usableWidth = collectionView!.bounds.width - sectionInset.left - sectionInset.right
		let perItemWidth = (usableWidth - CGFloat(columnsPerRow - 1) * minimumLineSpacing) / CGFloat(columnsPerRow)
		itemSize = CGSize(width: perItemWidth, height: heightPerRow)
	}
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
		if var attributes = super.layoutAttributesForElementsInRect(rect)! as? Array<UICollectionViewLayoutAttributes> {
			var sectionsWithoutHeaders = Set<Int>(map(attributes, { (layout) -> Int in return layout.indexPath.section }))
			
			for layout in filter(attributes, { (layout) -> Bool in return layout.representedElementCategory == .SupplementaryView }) {
				sectionsWithoutHeaders.remove(layout.indexPath.section)
			}
			
			// add in all section headers that aren't given by super. Will add headers that aren't on-screen as well
			for section in sectionsWithoutHeaders {
				attributes.append(layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: section)))
			}
			
			for layout in attributes {
				if let kind = layout.representedElementKind where kind == UICollectionElementKindSectionHeader {
					layout.frame = frameForHeaderLayout(layout)
				}
			}
			
			return attributes
		}
		return nil
	}
	
	override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
		var layout = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
		layout.frame = frameForHeaderLayout(layout)
		return layout
	}
	
	func frameForHeaderLayout(layout: UICollectionViewLayoutAttributes) -> CGRect {
		let itemIndex = max(0, collectionView!.numberOfItemsInSection(layout.indexPath.section) - 1)
		let firstInSection = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: layout.indexPath.section))
		let lastInSection = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: itemIndex, inSection: layout.indexPath.section))
		
		let y = min(max(collectionView!.contentOffset.y, firstInSection.frame.minY - layout.frame.height), lastInSection.frame.maxY)
		return CGRect(origin: CGPoint(x: layout.frame.minX, y: y), size: layout.frame.size)
	}
}
