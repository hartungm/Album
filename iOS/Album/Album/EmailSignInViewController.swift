//
//  CreateNewAccountViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/20/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class EmailSignInViewController : UIViewController, UITextFieldDelegate {
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	var ref : FIRDatabaseReference!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.emailTextField.delegate = self
		self.passwordTextField.delegate = self
		self.ref = FIRDatabase.database().reference()
	}
	
	@IBAction func signInEmail(_ sender: Any) {
		if(fieldsValid()) {
			FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
				if(error != nil) {
					print("Error in signing in with password authentication")
					_ = SimpleUIAlert(title: "Sign In Unsuccessful", message: "Sign in unsuccessful, please try again", sender: self)
					return
				}
				let User = UserDefaults.standard
				User.set(self.emailTextField.text!, forKey: "userName")
				User.set(self.passwordTextField.text!, forKey: "password")
				self.performSegue(withIdentifier: "SendToDashboard", sender: self)
			})
		}
	}
	
	func fieldsValid() -> Bool {
		if(emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty) {
			_ = SimpleUIAlert(title: "All required fields not filled in", message: "Please enter in an email and password.", sender: self)
			passwordTextField.text = ""
			return false
		}
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
