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
	var collectionContentSize: CGSize = CGSizeZero
	
	override init() {
		super.init()
		setupHelper()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		setupHelper()
	}
	
	override func prepareLayout() {
		var numSections: Int = (self.collectionView?.numberOfSections())!
		var rowsPerSection = [Int]()
		for sectNum in 0..<numSections {
			rowsPerSection.append((self.collectionView?.numberOfItemsInSection(sectNum))!)
		}
		
		var width: CGFloat = 0
		
		for section in 0..<numSections {
			var numCol: Int = Int(rowsPerSection[section] / 3) + ((rowsPerSection[section] % 3 == 0) ? 0 : 1)
			width += (CGFloat(numCol) * itemSize.width) + (sectionInset.left + sectionInset.right)
			width += CGFloat((numCol == 0) ? 0 : numCol - 1) * minimumLineSpacing
			
		}
		
		collectionContentSize = CGSize(width: width, height: 220.0)
	}
	
	override func collectionViewContentSize() -> CGSize {
		return collectionContentSize
	}
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
		var answer = super.layoutAttributesForElementsInRect(rect)! as Array<UICollectionViewLayoutAttributes>
		
		var sectNoSupp = [Int]()
		
		// count the section headers
		for layout in answer {
			if !(sectNoSupp as NSArray).containsObject(layout.indexPath.section) {
				sectNoSupp.append(layout.indexPath.section)
			}
		}
		
		for layout in answer {
			if layout.representedElementCategory == UICollectionElementCategory.SupplementaryView {
				var section = (sectNoSupp as NSArray).indexOfObject(layout.indexPath.section)
				sectNoSupp.removeAtIndex(section)
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
		itemSize = CGSize(width: 240, height: 60)
		minimumInteritemSpacing = 4.0
		minimumLineSpacing = 10.0 // not super set clean yet
		sectionInset = UIEdgeInsets(top: 30.0, left: 0.0, bottom: 2.0, right: 40.0)
	}
	
	func frameForHeaderLayout(layout: UICollectionViewLayoutAttributes) -> CGRect {
		var indexPath = layout.indexPath
		var frame = layout.frame
		
		let numItemsInSection = self.collectionView?.numberOfItemsInSection(indexPath.section)
		
		var firstCellAttributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: indexPath.section))
		var lastCellAttributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: max(0, (numItemsInSection! - 1)), inSection: indexPath.section))
		
		var width = (headerWidths.count - 1 >= indexPath.section) ? headerWidths[indexPath.section] : 240
		var minSpacingX: CGFloat = 4.0
		var xOne = max((self.collectionView?.contentOffset.x)! + minSpacingX, (firstCellAttributes.frame.minX))
		var x = min(xOne, lastCellAttributes.frame.maxX - frame.size.width)
		
		return CGRect(x: x, y: frame.origin.y, width: width, height: frame.size.height)
	}
}
