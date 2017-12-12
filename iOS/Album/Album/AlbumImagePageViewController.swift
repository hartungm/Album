//
//  AlbumImagePageViewController.swift
//  Album
//
//  Created by Michael Hartung on 3/23/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation

class AlbumImagePageViewController : UIPageViewController, UIPageViewControllerDataSource {
    
    var imageData : AlbumImageViewData = AlbumImageViewData()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.dataSource = self
		self.setViewControllers([getViewControllerAtIndex(index: self.imageData.index!)], direction: .forward, animated: true, completion: nil)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if self.imageData.index == 0 {
			self.imageData.index = (self.imageData.photos?.count)! - 1
		} else {
			self.imageData.index = self.imageData.index! - 1
		}
		return getViewControllerAtIndex(index: self.imageData.index!)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if self.imageData.index! == (self.imageData.photos?.count)! - 1 {
			self.imageData.index = 0
		} else {
			self.imageData.index = self.imageData.index! + 1
		}
		return getViewControllerAtIndex(index: self.imageData.index!)
	}
	
	func getViewControllerAtIndex(index: Int) -> AlbumImageViewController {
		let viewController = self.storyboard?.instantiateViewController(withIdentifier: "albumImageView") as! AlbumImageViewController
		viewController.photos = self.imageData.photos
		viewController.albumName = self.imageData.albumName
		viewController.photoURL = self.imageData.photos?[index]
		viewController.author = self.imageData.author
		
		return viewController
	}
	
	@IBAction func backToDashboard(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func backToDashboard2(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
}
