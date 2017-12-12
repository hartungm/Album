//
//  AppDelegate.swift
//  Album
//
//  Created by Michael Hartung on 2/12/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleSignIn
import Stripe
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let stripePublishableKey = "pk_test_jjGjLfxbklvOiUTM6n5rJHTB"
	let applePayIdentifier = "your apple merchant identifier"


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		STPPaymentConfiguration.shared().publishableKey = stripePublishableKey
		STPPaymentConfiguration.shared().appleMerchantIdentifier = applePayIdentifier
		FIRApp.configure()
		Fabric.with([STPAPIClient.self, Crashlytics.self])
		
		try! FIRAuth.auth()!.signOut()
		
		let User = UserDefaults.standard
		
		
		// Email Sign In
		if let myEmail = User.object(forKey: "userName") as? String {
			
			let password = User.object(forKey: "password") as! String
			
			FIRAuth.auth()?.signIn(withEmail: myEmail, password: password, completion: { (user, error) in
				
				if error == nil{
					let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
					self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "RootPageViewController")
				}
				else {
					let typeError = FIRAuthErrorCode(rawValue: error!._code)!
					switch typeError {
					case .errorCodeUserNotFound:
						print("user not found")
					case .errorCodeWrongPassword:
						print("wrong password")
					default:
						break
						
					}
				}
			})
		}
		
		// Facebook Sign in
		if(FBSDKAccessToken.current() != nil) {
			let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
			FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
				if let error = error {
					print(error)
					return
				}
				if user != nil {
					let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
					self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "NavigationController")
				}
			})
		}
		
		return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
	}
	
	// Facebook Sign In
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(
			application,
			open: url as URL!,
			sourceApplication: sourceApplication,
			annotation: annotation)
	}
	
	
//	 Google Sign In Methods
//	func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
//		return GIDSignIn.sharedInstance().handle(url,
//			sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
//			annotation: [:])
//	}
//	
//	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//		if (error != nil) {
//			return
//		}
//		guard let authentication = user.authentication else { return }
//		let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
//		return
//	}
//	
//	func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!, withError error: Error!) {
//		// Perform any operations when the user disconnects from app here.
//		// ...
//	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	// MARK: - Core Data stack
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "AlbumData")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	// MARK: - Core Data Saving support
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}


}

