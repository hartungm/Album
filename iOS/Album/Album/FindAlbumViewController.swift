//
//  FindAlbumViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/26/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class FindAlbumViewController : UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var albumName: UITextField!
	@IBOutlet weak var albumPassword: UITextField!
	var ref: FIRDatabaseReference!
	var album : NSDictionary?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationItem.title = "Find Album"
		self.ref = FIRDatabase.database().reference()
		self.albumName.delegate = self
		self.albumPassword.delegate = self
	}
	
	@IBAction func findAlbum(_ sender: Any) {
		if(validateFields()) {
			self.ref.child("albums").child(self.albumName.text ?? "").observeSingleEvent(of: .value, with: { (snapshot) in
				let value = snapshot.value as? NSDictionary
			
				if value == nil || (value?.count)! == 0 {
					_ = SimpleUIAlert(title: "Album Not Found", message: "Album Name/Password combination not found", sender: self)
					return
				} else if value?["password"] as? String != self.albumPassword.text! {
					_ = SimpleUIAlert(title: "Album Not Found", message: "Album Name/Password combination not found", sender: self)
					return
				}
			
				self.album = value
				self.performSegue(withIdentifier: "albumFound", sender: self)
			})
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "albumFound" {
			let viewController : AlbumFoundViewController = segue.destination as! AlbumFoundViewController
			viewController.album = self.album
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
