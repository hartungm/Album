//
//  AlbumImageViewController.swift
//  Album
//
//  Created by Michael Hartung on 3/12/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Nuke

class AlbumImageViewController : UIViewController {
	
	var ref: FIRDatabaseReference!
	@IBOutlet weak var imageView: UIImageView!
	var albumName : String?
	var photos : Array<URL>?
	var photoURL : URL?
	var author : String?
	@IBOutlet weak var deleteButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ref = FIRDatabase.database().reference()
		
		let request = Request(url: photoURL!)
		Nuke.loadImage(with: request, into: imageView)
		let storageRef = FIRStorage.storage().reference(forURL: photoURL!.absoluteString)
		deleteButton.isHidden = true
		
		storageRef.metadata { metadata, error in
			if error != nil {
				print("Error getting metadata")
			} else {
				if let userID = metadata?.customMetadata?["User"] as String? {
					if let author = self.author {
						if let user = FIRAuth.auth()?.currentUser {
							if author == user.uid ||  userID == user.uid {
								self.deleteButton.isHidden = false
							}
						}
					}
				}
			}
		}
		
		if let author = self.author {
			if let user = FIRAuth.auth()?.currentUser {
				if author == user.uid {
					deleteButton.isHidden = false
				}
			}
		}
	}
	
	@IBAction func setAsDefault(_ sender: Any) {
		self.ref.child("albums").child(albumName!).child("defaultPhoto").setValue(photoURL!.absoluteString)
		_ = SimpleUIAlert(title: "Image set as Default", message: "Image set as default for the \(albumName!) album.", sender: self)
	}
	
	@IBAction func savePhoto(_ sender: Any) {
		UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
		_ = SimpleUIAlert(title: "Image Saved", message: "Image saved to iPhotos Library", sender: self)
	}
	
	@IBAction func deletePhoto(_ sender: Any) {
		let alert = UIAlertController(title: "Delete Photo?", message: "Are you sure you would like to delete this Photo?", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in
			var newPhotos = NSArray()
			var i = 0
			while i < self.photos?.count ?? 0 {
				if let photo = self.photos?[i] {
					if photo.absoluteString != self.photoURL!.absoluteString {
						newPhotos = newPhotos.adding(photo.absoluteString) as NSArray
					}
				}
				i = i + 1
			}
			if let albumName = self.albumName {
				self.ref.child("albums").child(albumName).child("photos").setValue(newPhotos)
				self.ref.child("albums").child(albumName).child("numPhotos").setValue(newPhotos.count)
				
				let photoRef = FIRStorage.storage().reference(forURL: self.photoURL!.absoluteString)
				photoRef.delete { error in
					if let error = error {
						print("Error deleting file")
						print(error)
					}
					
					self.navigationController?.popViewController(animated: true)
				}
			}
		})
		alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in })
		self.present(alert, animated: true) { () -> Void in }
	}
	
	@IBAction func backToAlbum(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
}
