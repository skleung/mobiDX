//
//  LoginViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 11/28/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet var usernameField: UITextField!
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var loginButton: UIButton!
	@IBAction func login(sender: UIButton) {
		if (Util.checkTextFields([usernameField, passwordField], vc: self)) {
			PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!, block: { (user, err) -> Void in
				if user == nil {
					self.performSegueWithIdentifier("signupSegue", sender: self)
				} else {
					if (user!["patient"] as! Bool) {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							self.performSegueWithIdentifier("patientSegue", sender: self)
						})


					} else {
						self.performSegueWithIdentifier("physicianSegue", sender: self)
						NSUserDefaults.standardUserDefaults().setInteger(20, forKey: "queryLimit")
					}
				}
			})

		}
	}

	override func viewDidLoad() {
		let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
		view.addGestureRecognizer(tapGesture)
		loginButton.layer.cornerRadius = 7
	}

	func dismissKeyboard(sender: AnyObject?) {
		view.endEditing(true)
	}

	// MARK: Segue

	@IBAction func setUsername(segue: UIStoryboardSegue){
		// empty segue that allows for an unwind segue to return to this VC
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "signupSegue") {
			let signupVC = segue.destinationViewController as! SignUpViewController
			signupVC.username = usernameField.text ?? ""
			signupVC.password = passwordField.text ?? ""
		}
	}
}
