//
//  HorizontalFlow.swift
//  BruinLife
//
//  Created by Matthew DeCoste on 12/29/14.
//  Copyright (c) 2014 Matthew DeCoste. All rights reserved.
//

import UIKit

class HorizontalFlow: UICollectionViewFlowLayout {
	
	override init() {
		super.init()
		
		setupHelper()
	}

	required init(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		
		setupHelper()
	}
	
	func setupHelper() {
		scrollDirection = .Horizontal
		headerReferenceSize = CGSize(width: 120, height: 26)
		itemSize = CGSize(width: 240, height: 60)
		minimumInteritemSpacing = 4.0
		minimumLineSpacing = 10.0 // not super set clean yet
		sectionInset = UIEdgeInsets(top: 30.0, left: -100.0, bottom: 2.0, right: 30.0)
	}
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
		var answer = super.layoutAttributesForElementsInRect(rect)! as Array<UICollectionViewLayoutAttributes>
		var missingSections: Array<NSIndexPath> = []
		
		for layout in answer {
			if layout.representedElementCategory == .Cell {
				if layout.representedElementKind != nil && layout.representedElementKind != UICollectionElementKindSectionHeader {
					missingSections.append(NSIndexPath(forItem: 0, inSection: layout.indexPath.section))
				}
			}
		}
		
		for path in missingSections {
			answer.append(layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: path))
		}
		
		for layout in answer {
			if layout.representedElementKind != nil && layout.representedElementKind == UICollectionElementKindSectionHeader {
				let section = layout.indexPath.section
				let numItemsInSection = self.collectionView?.numberOfItemsInSection(section)
				
				var firstCellAttributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: section))
				var lastCellAttributes = layoutAttributesForItemAtIndexPath(NSIndexPath(forItem: max(0, (numItemsInSection! - 1)), inSection: section))
				
				if scrollDirection == .Vertical {
					var headerHeight = layout.frame.height
					var yOne = max((self.collectionView?.contentOffset.y)!, (firstCellAttributes.frame.minY - headerHeight))
					layout.frame.origin.y = min(yOne, (lastCellAttributes.frame.maxY - headerHeight))
					layout.zIndex = 1024
				} else {
					var headerWidth = layout.frame.width
					var minSpacingX: CGFloat = 4.0
					var xOne = max((self.collectionView?.contentOffset.x)! + minSpacingX, (firstCellAttributes.frame.minX))
					layout.frame.origin.x = min(xOne, lastCellAttributes.frame.maxX - headerWidth)
					layout.zIndex = 1024
				}
			}
		}
		
		return answer
	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		return true
	}
}
