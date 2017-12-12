//
//  UploadViewController.swift
//  Album
//
//  Created by Michael Hartung on 3/19/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class UploadViewController : UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	var albumName: String? = nil
	var imageSourceType : UIImagePickerControllerSourceType?
	var ref: FIRDatabaseReference!
	var storage: FIRStorageReference!

	override func viewDidLoad() {
		super.viewDidLoad()
		ref = FIRDatabase.database().reference()
		storage = FIRStorage.storage().reference()
		self.delegate = self
		self.sourceType = imageSourceType!
		self.allowsEditing = true
		UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
		self.topViewController?.title = "Camera"
		self.navigationBar.isTranslucent = false
		self.navigationBar.barStyle = UIBarStyle.blackOpaque
		
		self.setNavigationBarHidden(false, animated: false)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image: UIImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
			saveImage(image: image)
		}
		else if let image: UIImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
			saveImage(image: image)
		} else {
			_ = SimpleUIAlert(title: "Issue Saving Photo", message: "Camera could not save image, please try again.", sender: picker)
		}
		self.dismiss(animated: true, completion: nil);
	}
	
	func saveImage(image: UIImage) {
		if self.albumName != nil {
			let imageName = "\(arc4random()).jpg"
			let imageRef = storage.child("\(self.albumName!)/\(imageName)")
			let metadata = FIRStorageMetadata()
			metadata.contentType = "image/jpeg"
			if let user = FIRAuth.auth()?.currentUser {
				if metadata.customMetadata == nil {
					metadata.customMetadata = Dictionary<String, String>()
				}
				metadata.customMetadata?["User"] = user.uid
			}
			_ = imageRef.put(UIImagePNGRepresentation(image)!, metadata: metadata) { (metadata, error) in
				if error != nil {
					_  = SimpleUIAlert(title: "Issue saving Photo", message: "Photo not saved, possible network issue", sender: self)
					return
				}
				
				let downloadURL = metadata?.downloadURL()?.absoluteString
				self.ref.child("albums").child(self.albumName!).observeSingleEvent(of: .value, with: { (snapshot) in
					let albumValue = snapshot.value as? NSDictionary
					
					var photosArray = albumValue?["photos"] as? NSArray
					if photosArray == nil {
						photosArray = NSArray()
					}
					self.ref.child("albums").child(self.albumName!).child("photos").setValue(photosArray?.adding(downloadURL!))
					
					let numPhotos : Int = albumValue?["numPhotos"] as! Int
					self.ref.child("albums").child(self.albumName!).child("numPhotos").setValue(numPhotos + 1)
				}, withCancel: { (error) in
					print(error)
					_ = SimpleUIAlert(title: "Error occurred", message: "An error occurred connnecting to the database, please contact app support", sender: self)
				})
			}
		} else {
			_ = SimpleUIAlert(title: "Album Name not set", message: "Please set your album name", sender: self)
		}
	}
}
