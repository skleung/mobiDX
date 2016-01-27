//
//  DiagonsisViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 11/27/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit
import CoreData

class DiagonsisViewController: UIViewController {

	@IBOutlet var topImage: UIImageView!
	@IBOutlet var doneImage: UIImageView!
	@IBOutlet var negativeButton: UIButton!
	@IBOutlet var positiveButton: UIButton!

	var images:[ImageTag] = []
	var curImageTag:ImageTag?
	var tag:String = ""

	private var managedObjectContext: NSManagedObjectContext? = AppDelegate.managedObjectContext

	let SWIPE_DURATION = 0.4
    override func viewDidLoad() {
        super.viewDidLoad()
		loadTag()
		fetchImages()
		addSwipeGestures()
    }

	// every time the view appears, load the tag and fetch a fresh batch of images
	override func viewWillAppear(animated: Bool) {
		loadTag()
		addSwipeGestures()
		fetchImages()
		loadImage()
	}

	@IBAction func changeSettings(sender: UIBarButtonItem) {
		performSegueWithIdentifier("changeSettingsSegue", sender: self)
	}

	@IBAction func logout(sender: UIBarButtonItem) {
		PFUser.logOutInBackgroundWithBlock { (err) -> Void in
			if err == nil {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					self.performSegueWithIdentifier("unwindToLogin", sender: self)
				})
			}
		}
	}

	private func loadTag() {
		tag = NSUserDefaults.standardUserDefaults().stringForKey("tag") ?? ""
	}

	// fetches images from parse and loads them into CoreData
	private func fetchImages() {
		// clear images
		images = []

		// display progress indicator
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		hud.labelText = "Fetching from Parse..."

		// construct the query
		let query = PFQuery(className: "TaggedImage")
		if tag != "" {
			query.whereKey("tag", equalTo: tag)
		}
		var count = 1

		// grab query limit from userdefaults
		let limit = NSUserDefaults.standardUserDefaults().integerForKey("queryLimit")
		query.limit = limit
		// allows for nested query that retrieve Patient objects as well
		query.includeKey("patient")
		query.findObjectsInBackgroundWithBlock { (objs, err) -> Void in
			if err == nil, let objects = objs, let context = self.managedObjectContext {
				let queryCount = objects.count
				if queryCount == 0 {
					self.removeHudLoadImage(hud)
				}
				for obj in objects {
					let img = ImageTag.createImageTagFromParse(obj, data: nil, inManagedObjectContext: context)
					if img != nil {
						let file = obj["image"] as! PFFile
						file.getDataInBackgroundWithBlock({ (data, err) -> Void in
							if err == nil {
								img!.image = data
								self.images.append(img!)
								count += 1
								if (count >= queryCount) {

									self.updateDatabase()
									self.removeHudLoadImage(hud)
								}
							}
						})
					} else {
						count += 1
						if (count == queryCount) {
							self.removeHudLoadImage(hud)
						}
					}
				}
			} else {
				Util.displayAlert("Parse Error", message: (err?.localizedDescription)! , vc: self)
			}
		}
	}

	private func removeHudLoadImage(hud: MBProgressHUD!) {
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.loadImage()
			hud.hide(true)
		})
	}
	private func loadImage() {
		if images.count == 0 {
			removeSwipeGestures()
			UIView.animateWithDuration(0.4, animations: { () -> Void in
				self.topImage.alpha = 0
				}, completion: { (success) -> Void in
					if success {
						UIView.animateWithDuration(0.4, animations: { () -> Void in
							self.doneImage.hidden = false
						})
					}
			})
		} else {
			addSwipeGestures()
			topImage.alpha = 1
			curImageTag = images.removeAtIndex(0)
			topImage.image = UIImage(data: curImageTag!.image!)
		}
	}

	private func swipeLeft() {
		swipeHelper(-1.5, degree: 30)
	}

	private func swipeRight() {
		// flag the image if right-swiped
		curImageTag?.flagImage(inManagedObjectContext: managedObjectContext!)
		swipeHelper(1.5, degree: -30)
	}

	private func swipeHelper(translationCoefficient: CGFloat, degree: CGFloat) {
		// copies the image
		let imageCopy = UIImageView(frame: topImage.frame)
		imageCopy.image = topImage.image

		// updates the image
		loadImage()
		let tOffset = CGPoint(x: 0, y: CGRectGetHeight(topImage.bounds)*0.3)
		view.addSubview(imageCopy)
		UIView.animateWithDuration(SWIPE_DURATION, animations: { () -> Void in
			imageCopy.center = CGPoint(x: translationCoefficient*imageCopy.frame.width, y: self.topImage.center.y)
			imageCopy.alpha = 0
			var transform = CGAffineTransformMakeTranslation(tOffset.x, tOffset.y)
			transform = CGAffineTransformRotate(transform, -degree * CGFloat(M_PI / 180))
			transform = CGAffineTransformTranslate(transform, -tOffset.x, -tOffset.y)
			imageCopy.transform = transform
			}, completion: nil)
	}

	private func removeSwipeGestures() {
		if view.gestureRecognizers != nil {
			for gesture in view.gestureRecognizers! {
				if let recognizer = gesture as? UISwipeGestureRecognizer {
					view.removeGestureRecognizer(recognizer)
				}
			}
		}
		positiveButton.enabled = false
		negativeButton.enabled = false
	}

	private func addSwipeGestures() {
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: "swipeImage:")
		leftSwipe.direction = .Left
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: "swipeImage:")
		rightSwipe.direction = .Right
		view.addGestureRecognizer(leftSwipe)
		view.addGestureRecognizer(rightSwipe)
		positiveButton.enabled = true
		negativeButton.enabled = true
	}

	@IBAction func negativePressed(sender: UIButton) {
		swipeLeft()
	}

	@IBAction func positivePressed(sender: UIButton) {
		swipeRight()
	}

	func swipeImage(sender: UISwipeGestureRecognizer) {
		switch (sender.direction) {
			case UISwipeGestureRecognizerDirection.Left:
				swipeLeft()
			case UISwipeGestureRecognizerDirection.Right:
				swipeRight()
			default:
				break
		}
	}

	// MARK: - Core Data
	private func updateDatabase() {
		if let context = managedObjectContext {
			context.performBlock({ () -> Void in
				do {
					try context.save()
				} catch let error {
					print("Core Data Error \(error)")
				}
			})
		}
	}
}

// source: http://stackoverflow.com/questions/29779128/how-to-make-a-random-background-color-with-swift
extension UIColor {
	static func randomColor() -> UIColor {
		let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
		let g = CGFloat(arc4random()) / CGFloat(UInt32.max)
		let b = CGFloat(arc4random()) / CGFloat(UInt32.max)


		// If you wanted a random alpha, just create another
		// random number for that too.
		return UIColor(red: r, green: g, blue: b, alpha: 1.0)
	}
}
