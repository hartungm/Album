//
//  CreateNewAccountViewController.swift
//  Album
//
//  Created by Michael Hartung on 4/14/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class CreateNewAccountViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var confirmPasswordTextField: UITextField!
	var ref : FIRDatabaseReference!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.emailTextField.delegate = self
		self.passwordTextField.delegate = self
		self.confirmPasswordTextField.delegate = self
		self.ref = FIRDatabase.database().reference()
	}
	
	@IBAction func createAccount(_ sender: Any) {
		if(fieldsValid()) {
			FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
				if(error != nil) {
					print("Error in creating user account")
					return
				}
				if let user = user {
					let User = UserDefaults.standard
					User.set(self.emailTextField.text!, forKey: "userName")
					User.set(self.passwordTextField.text!, forKey: "password")
					self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: {(snapshot) in
						let userValue = snapshot.value as? NSDictionary
						if userValue == nil {
							self.ref.child("users").child(user.uid).child("displayName").setValue(user.displayName)
							self.ref.child("users").child(user.uid).child("email").setValue(user.email)
							
							// Created Date Formatter
							let dateFormatter = DateFormatter()
							dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss +zzzz"
							dateFormatter.locale = Locale.init(identifier: "en_GB")
							self.ref.child("users").child(user.uid).child("createdDate").setValue(dateFormatter.string(from: Date()))
						}
					})
					self.performSegue(withIdentifier: "sendToDashboard", sender: self)
				}
			})
		}
	}
	
	func fieldsValid() -> Bool {
		if(emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty || confirmPasswordTextField.text!.isEmpty) {
			_ = SimpleUIAlert(title: "All required fields not filled in", message: "Please enter in an email, password, and the confirm password fields.", sender: self)
			passwordTextField.text = ""
			confirmPasswordTextField.text = ""
			return false
		}
		
		if(passwordTextField.text! != confirmPasswordTextField.text!) {
			_ = SimpleUIAlert(title: "Passwords Mismatched", message: "Please ensure the password and confirm password fields match.", sender: self)
			passwordTextField.text = ""
			confirmPasswordTextField.text = ""
			return false
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
