//
//  AlbumGridFlowLayout.swift
//  Album
//
//  Created by Michael Hartung on 3/5/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation

class AlbumGridFlowLayout : UICollectionViewFlowLayout {
	
	let LINE_SPACING = 5
	let INTERIM_SPACING = 5
	var contentHeight : CGFloat = 0
	var contentWidth : CGFloat = 0
	
	var cellX : CGFloat = 0
	var cellY1 : CGFloat = 0
	var cellY2 : CGFloat = 0
	
	var attributesList = [UICollectionViewLayoutAttributes]()
	
	override func prepare() {
		if let collectionView = self.collectionView {
			attributesList = [UICollectionViewLayoutAttributes]()
			contentHeight = collectionView.frame.height
			contentHeight = collectionView.frame.width
			for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
				let indexPath = IndexPath(item: item, section: 0)
				let itemHeight = item % 3 > 1 ? itemWidth() * 1.5 : itemWidth()
				let cellY = item % 2 == 0 ? cellY1 : cellY2
				let itemFrame = CGRect(x: cellX, y: cellY, width: itemWidth(), height: itemHeight)
				itemFrame.insetBy(dx: CGFloat(INTERIM_SPACING), dy: CGFloat(LINE_SPACING))
				
				let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
				attributes.frame = itemFrame
				attributesList.append(attributes)
				
				if cellX > 0 {
					cellX = 0
				} else {
					cellX = itemWidth() + CGFloat(INTERIM_SPACING)
				}
				if item % 2 == 0 {
					cellY1 = cellY1 + itemHeight + CGFloat(LINE_SPACING)
				} else {
					cellY2 = cellY2 + itemHeight + CGFloat(LINE_SPACING)
				}
			}
			contentHeight = max(cellY1, cellY2, collectionView.frame.height)
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return attributesList
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return attributesList[indexPath.item]
	}
	
	override var collectionViewContentSize: CGSize {
		return CGSize(width: contentWidth, height: contentHeight)
	}
	
 
	/**
	Sets up the layout for the collectionView. 1pt distance between each cell and 1pt distance between each row plus use a vertical layout
	*/
//	func setupLayout() {
//		minimumInteritemSpacing = 5
//		minimumLineSpacing = 10
//		scrollDirection = .vertical
//	}
// 
	/// here we define the width of each cell, creating a 2 column layout. In case you would create 3 columns, change the number 2 to 3
	func itemWidth() -> CGFloat {
		return (collectionView!.frame.width/2) - 5
	}
 
//	override var itemSize: CGSize {
//		set {
//			let cellWidth = itemWidth()
//			self.itemSize = CGSize(width: cellWidth, height: cellWidth)
//		}
//		get {
//			let cellWidth = itemWidth()
//			return CGSize(width: cellWidth, height: cellWidth)
//		}
//	}
//	
// 
	override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
		return collectionView!.contentOffset
	}	
}
