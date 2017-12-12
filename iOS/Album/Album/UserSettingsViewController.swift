//
//  UserSettingsViewController.swift
//  Album
//
//  Created by Michael Hartung on 3/23/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class UserSettingViewController : UITableViewController {
	
	var ref: FIRDatabaseReference!
	var storage: FIRStorageReference!
	var displayName : String?
	var user : FIRUser?
	var albums: NSArray?
	
	@IBOutlet weak var displayNameTextField: UITextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.ref = FIRDatabase.database().reference()
		self.storage = FIRStorage.storage().reference()
		if let user = FIRAuth.auth()?.currentUser {
			self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
				if snapshot.value != nil {
					let user = snapshot.value as? NSDictionary
					self.displayName = user?["displayName"] as? String
					self.albums = user?["albums"] as? NSArray
				}
			})
		}
		self.displayNameTextField.text = self.displayName
	}
	
	@IBAction func saveSettings(_ sender: Any) {
		if let user = FIRAuth.auth()?.currentUser {
			self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: {(snapshot) in
				if snapshot.value != nil {
					self.ref.child("users").child(user.uid).child("displayName").setValue(self.displayNameTextField.text)
					if let albums = self.albums {
						var i = 0
						while(i < albums.count) {
							if let album = albums[i] as? String {
								self.ref.child("albums").child(album).child("authorName").setValue(self.displayNameTextField.text)
							}
							i = i + 1
						}
					}
				}
			})
		} else {
			_ = SimpleUIAlert(title: "Issue finding user", message: "Could not get your user account from the database, please try again later.", sender: self)
		}
		_ = self.navigationController?.popViewController(animated: true)
	}
}
