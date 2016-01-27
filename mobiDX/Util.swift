//
//  Util.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class Util {
	class func checkTextFields(textfields: [UITextField], vc: UIViewController) -> Bool {
		let empty = textfieldsAreEmpty(textfields)
		if empty {
			displayAlert("Empty Fields", message: "Please make sure to fill all textfields.", vc: vc)
		}
		return !empty
	}

	class func displayAlert(title: String, message: String, vc: UIViewController) {
		let alertView = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
			alertView.dismissViewControllerAnimated(true, completion: nil)
		})
		alertView.addAction(okAction)
		vc.presentViewController(alertView, animated: true, completion: nil)
	}

	private class func textfieldsAreEmpty(textfields: [UITextField]) -> Bool {
		for tf in textfields {
			let t = tf.text ?? ""
			if t == "" {
				return true
			}
		}
		return false
	}
}
