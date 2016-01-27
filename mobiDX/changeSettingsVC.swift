//
//  changeSettingsVC.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/8/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class changeSettingsVC: UIViewController {


	@IBOutlet var queryLimitSlider: UISlider!
	@IBOutlet var tagTextField: UITextField!
	@IBOutlet var saveButton: UIButton!

	override func viewDidLoad() {
		saveButton.layer.cornerRadius = 7
	}

	@IBAction func save(sender: AnyObject) {
		NSUserDefaults.standardUserDefaults().setInteger(Int(queryLimitSlider.value), forKey: "queryLimit")
		NSUserDefaults.standardUserDefaults().setObject(tagTextField.text, forKey: "tag")
		navigationController?.popViewControllerAnimated(true)
	}

}
