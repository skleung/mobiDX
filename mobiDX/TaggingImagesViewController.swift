//
//  TaggingImagesViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/3/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

class TaggingImagesViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, CLLocationManagerDelegate {

	var images:[UIImage] = []
	var locationManager = CLLocationManager()
	private var vcs:[TagImageViewController] = []
	private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))

	override func viewDidLoad() {
		vcs = createViewControllers()

		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()

		// resize the blur view
		blurView.frame = view.bounds

		setViewControllers(NSArray(object: vcs.first!) as! [UIViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
		dataSource = self
		delegate = self

		// creating a bar button programmatically
		let uploadButton = UIBarButtonItem(title: "Upload", style: UIBarButtonItemStyle.Done, target: self, action: "confirmTags:")
		navigationItem.rightBarButtonItem = uploadButton
	}

	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		let tagVC = viewController as? TagImageViewController
		if let _ = tagVC {
			var i = vcs.indexOf(tagVC!)!
			if (i >= vcs.count - 1) {
				return nil
			}
			i+=1
			return vcs[i]

		}
		return vcs[vcs.count - 1]
	}

	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		let tagVC = viewController as? TagImageViewController
		if let _ = tagVC {
			var i = vcs.indexOf(tagVC!)!
			if (i <= 0) {
				return nil
			}
			i-=1
			return vcs[i]
		}
		return vcs[0]
	}

	func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
		return vcs.count
	}

	private func createViewControllers() -> [TagImageViewController] {
		var vcs:[TagImageViewController] = []
		for image in images {
			let vc = TagImageViewController()
			vc.image = image
			vcs.append(vc)
		}
		return vcs
	}

	func confirmTags(sender: AnyObject?) {
		// blur the existing image
		view.addSubview(blurView)

		let confirmAlert = UIAlertController(title: "Confirm upload?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
		confirmAlert.addTextFieldWithConfigurationHandler { (tf) -> Void in
			tf.placeholder = "Add an optional tag."
		}
		let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
			UIAlertAction in
			for (i, vc) in self.vcs.enumerate() {
				let image = vc.image
				if let _ = image {
					let data = UIImageJPEGRepresentation(image!, 1.0)
					let tag = confirmAlert.textFields?.first?.text
					let tagString = tag ?? ""
					self.upload(data, tagString: tagString, fileName: "image"+String(i))
				}
			}
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
			UIAlertAction in
			self.blurView.removeFromSuperview()
			self.dismissViewControllerAnimated(true, completion: nil)
		}

		confirmAlert.addAction(okAction)
		confirmAlert.addAction(cancelAction)
		presentViewController(confirmAlert, animated: true, completion: nil)
	}

	private func upload(data: NSData?, tagString: String, fileName:String) {
		if Reachability.isConnectedToNetwork() {
			// we can upload to Parse
			let newTaggedImage = PFObject(className: "TaggedImage")
			let file = PFFile(name: fileName, data: data!)
			if let _ = file {
				newTaggedImage.setObject(file!, forKey: "image")
			}
			newTaggedImage.setObject(tagString, forKey: "tag")
			newTaggedImage.setValue(0, forKey: "reviews")
			newTaggedImage["patient"] = PFUser.currentUser()
			PFGeoPoint.geoPointForCurrentLocationInBackground({ (geopoint, err) -> Void in
				let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
				hud.labelText = "Uploading..."
				if err == nil {
					newTaggedImage.setObject(geopoint!, forKey: "location")
				}
				newTaggedImage.saveInBackgroundWithBlock({ (success, error) -> Void in
					// hiding the HUD as an operation on the main queue
					dispatch_async(dispatch_get_main_queue()) {
						hud.hide(true)
						self.performSegueWithIdentifier("unwindToCamera", sender: self)
					}
				})
			})
		} else {
			Util.displayAlert("No Internet Connection", message: "Please connect to the internet and upload again!", vc: self)
		}
	}

	private func trimString(input: String?) -> String? {
		if let _ = input {
			if (input!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
				return nil
			}
			return input
		}
		return nil
	}
}
