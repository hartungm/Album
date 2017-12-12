//
//  SimpleUIAlert.swift
//  Album
//
//  Created by Michael Hartung on 2/20/17.
//  Copyright © 2017 hartung-michael. All rights reserved.
//

import Foundation

class SimpleUIAlert {
	
	init(title: String, message: String, sender : UIViewController) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
		alert.addAction(alertAction)
		sender.present(alert, animated: true) { () -> Void in }
	}
}
