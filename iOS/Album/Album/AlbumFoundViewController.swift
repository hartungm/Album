//
//  AlbumFoundViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/26/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class AlbumFoundViewController : UIViewController {
	
	var album : NSDictionary? = nil
	var ref : FIRDatabaseReference!
	var storage : FIRStorageReference!
	@IBOutlet weak var albumFoundLabel: UILabel!
	@IBOutlet weak var defaultImageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.activityIndicator.startAnimating()
		self.navigationItem.title = "'\(album?["name"] as! String)' Found"
		self.albumFoundLabel.text = "Album '\(album?["name"] as! String)' Found\nAdd To Dashboard?"
		self.ref = FIRDatabase.database().reference()
		storage = FIRStorage.storage().reference()
		if let defaultPhoto = album?["defaultPhoto"] as? String {
			let image = storage.child("\(album?["name"] as! String)/\(defaultPhoto)")
			image.data(withMaxSize: 1 * 1024 * 1024 * 1024, completion: { (data, error) in
				if let error = error {
					print(error)
				} else {
					if let image = UIImage(data: data!) {
						self.defaultImageView.image = image
					}
				}
				self.activityIndicator.stopAnimating()
			})
		} else {
			self.activityIndicator.stopAnimating()
		}
	}
	
	@IBAction func addToDashboard(_ sender: Any) {
		if let user = FIRAuth.auth()?.currentUser {
			self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
				let userValue = snapshot.value as? NSDictionary
				if let albumsArray = userValue?["albums"] as? NSArray {
					self.ref.child("users").child(user.uid).child("albums").setValue(albumsArray.adding(self.album?["name"] as! String))
				} else {
					self.ref.child("users").child(user.uid).child("albums").setValue(NSArray().adding(self.album?["name"] as! String))
				}
				_ = self.navigationController?.popToRootViewController(animated: true)
			}, withCancel: { (error) in
				print(error)
				_ = SimpleUIAlert(title: "Error occurred", message: "An error occurred connnecting to the databse, please contact app support", sender: self)
			})
		}
	}
	
	@IBAction func cancel(_ sender: Any) {
		_ = self.navigationController?.popToRootViewController(animated: true)
	}
}
