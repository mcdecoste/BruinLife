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
			if layout.representedElementCategory == UICollectionElementCategory.SupplementaryView {
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
		
		return CGRect(x: x, y: layout.frame.origin.y, width: width, height: layout.frame.height)
	}
}

class VerticalFlow: UICollectionViewFlowLayout {
	private let columnsPerRow: Int = 2
	
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
			height += numRows * (itemSize.height + minimumLineSpacing) + sectionInset.top + sectionInset.bottom
		}
		
		return CGSize(width: collectionView!.bounds.width, height: height)
	}
	
//	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
//		var answer = super.layoutAttributesForElementsInRect(rect)! as! Array<UICollectionViewLayoutAttributes>
//		var sectNoSupp: Array<Int> = []
//		
//		// count the section headers
//		for layout in answer {
//			if find(sectNoSupp, layout.indexPath.section) == nil {
//				sectNoSupp.append(layout.indexPath.section)
//			}
//		}
//		
//		for layout in answer {
//			if layout.representedElementCategory == UICollectionElementCategory.SupplementaryView {
//				sectNoSupp.removeAtIndex(find(sectNoSupp, layout.indexPath.section)!)
//			}
//		}
//		
//		for section in sectNoSupp {
//			answer.append(self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: section)))
//		}
//		
//		for layout in answer {
//			if layout.representedElementKind != nil && layout.representedElementKind == UICollectionElementKindSectionHeader {
//				layout.frame = frameForHeaderLayout(layout)
//			}
//		}
//		
//		return answer
//	}
//	
//	override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
//		var layout: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
//		layout.frame = frameForHeaderLayout(layout)
//		return layout
//	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		return true
	}
	
	// MARK: Helpers
	func setupHelper() {
		headerReferenceSize = CGSize(width: 10, height: 26)
		itemSize = CGSize(width: 240, height: 100)
		minimumInteritemSpacing = 4
		minimumLineSpacing = 10 // not super set clean yet
		sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 10)
	}
	
//	func frameForHeaderLayout(layout: UICollectionViewLayoutAttributes) -> CGRect {
//		let indexPath = layout.indexPath
//		let itemIndex = max(0, collectionView!.numberOfItemsInSection(indexPath.section) - 1)
//		
//		let firstAttr = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: indexPath.section))
//		let lastAttr = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: itemIndex, inSection: indexPath.section))
//		
//		let width = headerWidths.count - 1 >= indexPath.section ? headerWidths[indexPath.section] : 240
//		let x = min(max(collectionView!.contentOffset.x + 4, firstAttr.frame.minX), lastAttr.frame.maxX - width)
//		
//		return CGRect(x: x, y: layout.frame.origin.y, width: width, height: layout.frame.height)
//	}
}
