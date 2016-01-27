//
//  TagImageViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/5/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class TagImageViewController: UIViewController, DrawImageDelegate {
	var image: UIImage?

	override func viewDidLoad() {
		setBackgroundImage()

		// add the touch event to bring up a drawVC
		let touchGesture = UITapGestureRecognizer(target: self, action: "drawOnImage:")
		view.addGestureRecognizer(touchGesture)
	}

	func drawOnImage(sender: AnyObject?) {
		let drawVC = DrawViewController()
		drawVC.image = self.image
		drawVC.delegate = self
		self.presentViewController(drawVC, animated: true) { () -> Void in
			print("presented drawVC")
		}
	}

	private func setBackgroundImage() {
		UIGraphicsBeginImageContext(self.view.frame.size)
		image!.drawInRect(self.view.bounds)
		let bgImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		view.backgroundColor = UIColor(patternImage: bgImage)
	}

	func didUpdateImage(newImage: UIImage) {
		image = newImage
		setBackgroundImage()
	}
}
