//
//  DrawViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/4/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit

protocol DrawImageDelegate {
	func didUpdateImage(image: UIImage)
}

class DrawViewController: UIViewController {
	var image: UIImage?
	var lastPoint: CGPoint?
	var r:CGFloat = 0
	var b:CGFloat = 0
	var g:CGFloat = 0

	var canvas: UIImageView?
	var delegate: DrawImageDelegate?

	override  func viewDidLoad() {
		if canvas == nil {
			canvas = UIImageView(frame: self.view.frame)
			view.addSubview(canvas!)
		}
		if let _image = image {
			canvas!.image = _image
		}

		// create nav bar programmatically
		let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 64)) // Offset by 20 pixels vertically to take the status bar into account

		navigationBar.backgroundColor = UIColor.whiteColor()
		let navigationItem = UINavigationItem()
		navigationItem.title = "Tagging Image"

		let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneDrawing:")

		navigationItem.rightBarButtonItem = rightButton

		// Assign the navigation item to the navigation bar
		navigationBar.items = [navigationItem]

		// Make the navigation bar a subview of the current view controller
		self.view.addSubview(navigationBar)

		let doubleTap = UITapGestureRecognizer(target: self, action: "doneDrawing:")
		doubleTap.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTap)
	}

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let startTouchEvent = touches.first
		if let start = startTouchEvent {
			let p = start.locationInView(canvas!)
			lastPoint = p
		}
	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let touchEvent = touches.first
		if let touch = touchEvent, let last = lastPoint {
			let p = touch.locationInView(canvas!)
			draw(last, to: p)
			lastPoint = p
		}
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		lastPoint = nil
	}

	private func draw(from: CGPoint, to: CGPoint) {

		//		let context = setupContext()
		UIGraphicsBeginImageContext(canvas!.frame.size)
		canvas!.image?.drawInRect(canvas!.frame)
		let context = setupContext()

		CGContextMoveToPoint(context, from.x, from.y)
		CGContextAddLineToPoint(context, to.x, to.y)

		CGContextSetRGBStrokeColor(context, r, g, b, 1.0)
		CGContextStrokePath(context)

		canvas!.image = UIGraphicsGetImageFromCurrentImageContext()
		image = canvas!.image
		UIGraphicsEndImageContext()
	}

	func doneDrawing(sender: AnyObject?) {
		delegate?.didUpdateImage(image!)
		presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}

		private func setupContext() -> CGContextRef {
			let context = UIGraphicsGetCurrentContext()
			CGContextSetLineWidth(context, 3.0)
			CGContextSetStrokeColorWithColor(context, UIColor.blackColor().CGColor)
			CGContextStrokeRect(context, view.bounds)
			return context!
		}
}
