//
//  SignUpViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet var patientPhysicianControl: UISegmentedControl!

	@IBOutlet var usernameField: UITextField!
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var firstNameField: UITextField!
	@IBOutlet var lastNameField: UITextField!
	@IBOutlet var phoneField: UITextField!
	@IBOutlet var emailField: UITextField!
	@IBOutlet var ageOrTagField: UITextField!
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var maleOrFemale: UISegmentedControl!

	var activeTextField:UITextField? = nil
	var username = ""
	var password = ""

	private var isPatient = true

	override func viewWillLayoutSubviews() {
		// sets content size to lock the width and allow for vertical scrolling
		scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 200)
	}
	override func viewDidLoad() {


		// sets username/password if exists
		usernameField.text = username
		passwordField.text = password

		// create nav bar programmatically
		let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64))
		navigationBar.backgroundColor = UIColor.whiteColor()
		let navigationItem = UINavigationItem()
		navigationItem.title = "Tagging Image"

		let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "signUp:")
		navigationItem.rightBarButtonItem = rightButton


		let leftButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "dismissView:")
		navigationItem.leftBarButtonItem = leftButton

		// Assign the navigation item to the navigation bar
		navigationBar.items = [navigationItem]
		view.addSubview(navigationBar)

		// Assign responders to keyboard notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		let tapGesture = UITapGestureRecognizer(target: self, action: "dismissKeyboard:")
		scrollView.addGestureRecognizer(tapGesture)
	}

	@IBAction func toggleForm(sender: UISegmentedControl) {
		let shouldFlip = isPatient != (sender.selectedSegmentIndex == 0)
		isPatient = sender.selectedSegmentIndex == 0
		self.ageOrTagField.keyboardType = self.isPatient ? UIKeyboardType.NumberPad : UIKeyboardType.Alphabet

		if shouldFlip {
			UIView.transitionWithView(ageOrTagField, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
				self.ageOrTagField.placeholder = self.isPatient ? "Age (years)" : "Area/Discipline"
				}, completion: nil)
		}
	}

	func dismissKeyboard(sender: AnyObject?) {
		view.endEditing(true)
	}

	func dismissView(sender: AnyObject?) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func signUp(sender: AnyObject?) {
		if (Util.checkTextFields([usernameField, passwordField, firstNameField, lastNameField, phoneField, emailField, ageOrTagField], vc: self)) {
			let newUser = PFUser()
			newUser["username"] = usernameField.text
			newUser["password"] = passwordField.text
			newUser["patient"] = isPatient
			newUser["first_name"] = firstNameField.text
			newUser["phone"] = phoneField.text
			newUser["last_name"] = lastNameField.text
			newUser["email"] = emailField.text
			newUser["gender"] = maleOrFemale.selectedSegmentIndex == 0 ? "M" : "F"

			if isPatient {
				newUser["age"] = Int(ageOrTagField.text ?? "0")
			} else {
				newUser["tag"] = ageOrTagField.text
			}
			newUser.signUpInBackgroundWithBlock { (success, err) -> Void in
				if err == nil {
					if self.isPatient {
						self.dismissViewControllerAnimated(true, completion: nil)
					} else {
						//sets the default tag for the physician
						NSUserDefaults.standardUserDefaults().setObject(self.ageOrTagField.text ?? "", forKey: "tag")
						self.dismissViewControllerAnimated(true, completion: nil)
					}
				}
			}
		}
	}

	// leveraging the fact that shouldBegin gets called before the NSNotification kicks in
	func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
		activeTextField = textField
		return true
	}

	// MARK: Keyboard NSNotifications callbacks
	private let keyboardMarginThreshold = CGFloat(20)
	func keyboardWillShow(notification: NSNotification) {
	  if let userInfo = notification.userInfo {
		if let keyboardSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size {
			var contentInset:UIEdgeInsets = self.scrollView.contentInset

			// calculates offset based on where the activeTextField is
			var textfieldOffset = CGFloat(0)
			if let _ = activeTextField {
				if activeTextField!.frame.maxY > (view.frame.maxY - keyboardSize.height - keyboardMarginThreshold) {
					textfieldOffset = activeTextField!.frame.maxY - (scrollView.frame.height - keyboardSize.height) + keyboardMarginThreshold
				}
			}
			contentInset.bottom = keyboardSize.height + textfieldOffset
			self.scrollView.contentInset = contentInset
		}
	  }
	}

	func keyboardWillHide(notification: NSNotification) {
		// resets the scroll view
		self.scrollView.contentInset = UIEdgeInsetsZero
	}
}
