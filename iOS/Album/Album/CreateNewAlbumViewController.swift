//
//  CreateNewAlbumViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/25/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class CreateNewAlbumViewController : UIViewController, UITextFieldDelegate {
	
	var displayName : String? = nil
	var ref: FIRDatabaseReference!
	@IBOutlet weak var albumName: UITextField!
	@IBOutlet weak var albumPassword: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "Create New Album"
		self.ref = FIRDatabase.database().reference()
		self.albumName.delegate = self
		self.albumPassword.delegate = self
	}
	
	@IBAction func createNewAlbum(_ sender: Any) {
		if(validateFields()) {
			if let user = FIRAuth.auth()?.currentUser {
				self.ref.child("albums").child(albumName.text ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
					let value = snapshot.value as? NSDictionary
					if value != nil && (value?.count)! > 0 {
						_ = SimpleUIAlert(title: "Name already used", message: "This album name is already in use, please choose another", sender: self)
						return
					} else {
						self.ref.child("albums").child(self.albumName.text!).child("author").setValue(user.uid)
						if let displayName = self.displayName {
							self.ref.child("albums").child(self.albumName.text!).child("authorName").setValue(displayName)
						} else {
							self.ref.child("albums").child(self.albumName.text!).child("authorName").setValue(user.email)
						}
						self.ref.child("albums").child(self.albumName.text!).child("name").setValue(self.albumName.text!)
						self.ref.child("albums").child(self.albumName.text!).child("numPhotos").setValue(0)
						self.ref.child("albums").child(self.albumName.text!).child("password").setValue(self.albumPassword.text!)
					
						self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
							let userValue = snapshot.value as? NSDictionary
							var albumsArray = userValue?["albums"] as? NSArray
							if albumsArray == nil {
								albumsArray = NSArray()
							}
							self.ref.child("users").child(user.uid).child("albums").setValue(albumsArray?.adding(self.albumName.text!))
							_ = self.navigationController?.popToRootViewController(animated: true)
						}, withCancel: { (error) in
							print(error)
							_ = SimpleUIAlert(title: "Error occurred", message: "An error occurred connnecting to the database, please contact app support", sender: self)
						})
					}
				}, withCancel: { (error) in
					print(error)
					_ = SimpleUIAlert(title: "Error occurred", message: "An error occurred connnecting to the database, please contact app support", sender: self)
					return
				})
			}
		}
	}
	
	func validateFields() -> Bool {
		if self.albumName.text!.isEmpty || self.albumPassword.text!.isEmpty {
			_ = SimpleUIAlert(title: "All required fields not filled in", message: "Please fill in all fields", sender: self)
			self.albumName.text = ""
			self.albumPassword.text = ""
			return false
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
