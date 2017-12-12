//
//  DashboardViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/20/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MobileCoreServices
import Nuke

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
	
	var ref: FIRDatabaseReference!
	var albums: NSArray?
	var displayName: String?
	var albumName : String?
	var defaultAlbum : String?
	var photos : Array<URL>?
	@IBOutlet weak var tableView: UITableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let refresh = UIRefreshControl()
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		refresh.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
		self.tableView.addSubview(refresh)
		
		let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightAction))
		swipeRight.direction = UISwipeGestureRecognizerDirection.right
		self.view.addGestureRecognizer(swipeRight)
	}
	
	func handleRefresh(refreshControl: UIRefreshControl) {
		getUsersAlbums()
		refreshControl.endRefreshing()
	}
	
	func swipeRightAction(_ gesture: UIGestureRecognizer) {
		self.navigationController?.popViewController(animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.ref = FIRDatabase.database().reference()
		getUsersAlbums()
	}
	
	@IBAction func showCamera(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return albums?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DashboardTableViewCell
		
		if let albumName = albums?[indexPath.row] as? String {
			// Grab the album
			self.ref.child("albums").child(albumName).observeSingleEvent(of: .value, with: {(snapshot) in
				let albumValue = snapshot.value as? NSDictionary
				
				// Set album text color to gold if it is the default
				if self.defaultAlbum == albumValue?["name"] as? String {
					cell.albumNameText.textColor = UIColor(red:0.93, green:0.78, blue:0.26, alpha:1.0)
					cell.authorNameText.textColor = UIColor(red:0.93, green:0.78, blue:0.26, alpha:1.0)
					cell.numberOfPhotosText.textColor = UIColor(red:0.93, green:0.78, blue:0.26, alpha:1.0)
				} else {
					cell.albumNameText.textColor = UIColor.white
					cell.authorNameText.textColor = UIColor.white
					cell.numberOfPhotosText.textColor = UIColor.white

				}
				
				// Set the Album Name, Author Name, and Number of Photos
				cell.albumNameText?.text = albumValue?["name"] as? String
				cell.authorNameText?.text = "by \(albumValue?["authorName"] as! NSString)"
				cell.numberOfPhotosText?.text = "\(albumValue?["numPhotos"] as! NSNumber)"
				
				if let photos = albumValue?["photos"] as? Array<String> {
                    cell.photos = Array()
					for photo in photos {
						cell.photos.append(URL(string: photo)!)
					}
					cell.photos.reverse()
				}
				
				if let defaultPhoto = albumValue?["defaultPhoto"] as? String {
					let request = Request(url: URL(string: defaultPhoto)!)
					Nuke.loadImage(with: request, into: cell.albumImageView)
				}
			})
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let makeDefault = UITableViewRowAction(style: .normal, title: "Make\nDefault") { (action, index) in
			if let albumName = self.albums?[indexPath.row] as? String {
				self.defaultAlbum = albumName
				if let user = FIRAuth.auth()?.currentUser {
					self.ref.child("users").child(user.uid).child("defaultAlbum").setValue(albumName)
					self.tableView.reloadData()
				}
			}
		}
		makeDefault.backgroundColor = UIColor(red:0.93, green:0.78, blue:0.26, alpha:1.0)
		
		let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
			if let albumName = self.albums?[indexPath.row] as? String {
				var newAlbums = NSArray()
				var i = 0
				while i < self.albums?.count ?? 0 {
					if let iAlbum = self.albums?[i] as? String {
						if albumName != iAlbum {
							newAlbums = newAlbums.adding(iAlbum) as NSArray
						}
					}
					i = i + 1
				}
				if let user = FIRAuth.auth()?.currentUser {
					self.ref.child("users").child(user.uid).child("albums").setValue(newAlbums)
					self.getUsersAlbums()
				} else {
					_ = SimpleUIAlert(title: "Error", message: "Error deleting album from your account.", sender: self)
				}
			}
		}
		delete.backgroundColor = UIColor.black
		
		return [delete, makeDefault]
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! DashboardTableViewCell
		self.albumName = cell.albumNameText.text
		self.photos = cell.photos
		performSegue(withIdentifier: "albumDashboard", sender: self)
	}
	
	func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		if(item.tag == 1) {
			performSegue(withIdentifier: "findAlbum", sender: self)
		} else if(item.tag == 2) {
			performSegue(withIdentifier: "createAlbum", sender: self)
		} else if(item.tag == 3) {
			performSegue(withIdentifier: "userSettings", sender: self)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "createAlbum") {
			let viewController : CreateNewAlbumViewController = segue.destination as! CreateNewAlbumViewController
			viewController.displayName = self.displayName
		}
		if segue.identifier == "albumDashboard" {
			let viewController : AlbumDashboardViewController = segue.destination as! AlbumDashboardViewController
			viewController.albumName = self.albumName!
			if let photos = self.photos {
				viewController.photos = photos
			}
			viewController.photos.reverse()
		}
		if segue.identifier == "useCamera" {
			let viewController : CameraViewController = segue.destination as! CameraViewController
			viewController.albumName = self.defaultAlbum
		}
		if segue.identifier == "userSettings" {
			let viewController : UserSettingViewController = segue.destination as! UserSettingViewController
			viewController.displayName = self.displayName
		}
	}
	
	func getUsersAlbums() {
		if let user = FIRAuth.auth()?.currentUser {
			let userid = user.uid
			self.ref.child("users").child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
				let user = snapshot.value as? NSDictionary
				self.albums = user?["albums"] as? NSArray
				self.displayName = user?["displayName"] as? String
				if self.displayName == nil {
					self.displayName = user?["email"] as? String
				}
				self.defaultAlbum = user?["defaultAlbum"] as? String
				self.tableView.reloadData()
			}, withCancel: { (error) in
				print(error.localizedDescription)
			})
		}
	}
}
