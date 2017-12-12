//
//  RootPageViewController.swift
//  Album
//
//  Created by Michael Hartung on 5/14/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class RootPageViewController : UIPageViewController, UIPageViewControllerDataSource {
	
	var ref: FIRDatabaseReference!
	var defaultAlbum : String?
	var author : String?
	var photos : Array<URL>?
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		self.ref = FIRDatabase.database().reference()
		
		if let user = FIRAuth.auth()?.currentUser {
			let userid = user.uid
			self.ref.child("users").child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
				let userValue = snapshot.value as? NSDictionary
				self.defaultAlbum = userValue?["defaultAlbum"] as? String
				if let albumName = self.defaultAlbum{
					// Grab the album
					self.ref.child("albums").child(albumName).observeSingleEvent(of: .value, with: {(snapshot) in
						let albumValue = snapshot.value as? NSDictionary
						
						self.author = albumValue?["authorName"] as? String
						
						if let photos = albumValue?["photos"] as? Array<String> {
							self.photos = Array()
							for photo in photos {
								self.photos?.append(URL(string: photo)!)
							}
							self.photos?.reverse()
						}
					})
				}
			}, withCancel: { (error) in
				print(error.localizedDescription)
			})
		}
	}
		
	override func viewDidLoad() {
		super.viewDidLoad()
		self.dataSource = self
		self.setViewControllers([(self.storyboard?.instantiateViewController(withIdentifier: "AlbumCameraViewController"))!], direction: .forward, animated: true, completion: nil)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if viewController is DashboardViewController {
			return self.storyboard?.instantiateViewController(withIdentifier: "AlbumCameraViewController")
		}
		if viewController is AlbumCameraViewController {
			let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "AlbumNavController")
			return newViewController
		}
		return nil
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if viewController is AlbumCameraViewController {
			return self.storyboard?.instantiateViewController(withIdentifier: "DashboardNavController")
		}
		return nil
	}

}
