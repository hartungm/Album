//
//  SignInViewController.swift
//  Album
//
//  Created by Michael Hartung on 2/18/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import FirebaseAuth
import FirebaseDatabase
import Foundation
import GoogleSignIn
import UIKit

class SignInViewController: UIViewController, GIDSignInUIDelegate {
	
	var ref : FIRDatabaseReference!
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.ref = FIRDatabase.database().reference()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		GIDSignIn.sharedInstance().uiDelegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func signInWithFacebook(_ sender: Any) {
		let manager: FBSDKLoginManager = FBSDKLoginManager()
		manager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) -> Void in
			if (error != nil) {
				// Handle errors
			}
			
			if (result?.isCancelled)! {
				return
			}
			else if (result?.grantedPermissions.contains("email"))! {
				self.attemptSignInWithFacebook()
			}
		})
	}
	
	func attemptSignInWithFacebook() {
		if(FBSDKAccessToken.current() != nil) {
			let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
			FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
				if let error = error {
					print(error)
					return
				}
				if let user = user {
					self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: {(snapshot) in
						self.ref.child("users").child(user.uid).child("displayName").setValue(user.displayName)
						self.ref.child("users").child(user.uid).child("email").setValue(user.email)
					})
					self.performSegue(withIdentifier: "SignIn", sender: self)
				}
			})
		}
	}
	
//	@IBAction func signInWithGoogle(_ sender: Any) {
//		GIDSignIn.sharedInstance().signIn()
//	}
	
//	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//		if (error != nil) {
//			return
//		}
//		guard let authentication = user.authentication else { return }
//		let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
//		FIRAuth.auth()?.signIn(with: credential) { (user, error) in
//			if (error != nil) {
//				return
//			}
//			self.performSegue(withIdentifier: "SignIn", sender: self)
//		}
//	}
}
