//
//  BalanceCameraViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 11/27/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

class BalanceCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	@IBOutlet var capturedImage: UIImageView!
	@IBOutlet var viewFinder: UIView!
	@IBOutlet var numPictures: UILabel!
	@IBOutlet var instructionsLabel: UILabel!

	var session: AVCaptureSession?
	var stillImageConnection: AVCaptureConnection?
	var stillImageOutput: AVCaptureStillImageOutput?
	var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	var images: [UIImage] = [] {
		didSet {
			if (images.count > 0) {
				numPictures.text = "\(images.count)"
			} else {
				numPictures.text = " "
			}
		}
	}

	override func viewDidLoad() {
		// tap gesture to take photos
		let tapGesture = UITapGestureRecognizer(target: self, action: "tapViewFinder:")
		viewFinder.addGestureRecognizer(tapGesture)

		// remove the instructions label after a slight delay
		view.bringSubviewToFront(instructionsLabel)
		NSTimer.scheduledTimerWithTimeInterval(2.5, target: self, selector: "removeInstructions:", userInfo: nil, repeats: false)

		// set up the AVFoundation capture
		session = AVCaptureSession()
		session!.sessionPreset = AVCaptureSessionPresetMedium
		let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		var error: NSError?
		var input: AVCaptureDeviceInput!
		do {
			input = try AVCaptureDeviceInput(device: backCamera)
		} catch let error1 as NSError {
			error = error1
			input = nil
			print(error!.localizedDescription)
		}
		if error == nil && session!.canAddInput(input) {
			session!.addInput(input)
			stillImageOutput = AVCaptureStillImageOutput()
			stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
			if session!.canAddOutput(stillImageOutput) {
				session!.addOutput(stillImageOutput)
				stillImageConnection = stillImageOutput!.connections.first as! AVCaptureConnection!
				session!.startRunning()

				videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
				videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
				videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
				videoPreviewLayer!.contentsScale = UIScreen.mainScreen().scale
				viewFinder.layer.addSublayer(videoPreviewLayer!)
			}
		}
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		videoPreviewLayer!.frame = viewFinder.bounds
	}


	// citation: http://stackoverflow.com/questions/26641443/how-to-take-multiple-photos-in-a-sequence-1s-delay-each-using-swift-on-ios8-1
	private func takePhoto(completion: (UIImage?, NSError?) -> Void) {
		// TODO: use if let here
		self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(self.stillImageConnection!) { buffer, error in
			if let error = error {
				completion(nil, error)
			} else {
				let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
				let image = UIImage(data: imageData, scale: UIScreen.mainScreen().scale)
				completion(image, nil)
			}
		}
	}

	@IBAction func chooseFromCameraRoll(sender: UIBarButtonItem) {
		let vc = UIImagePickerController()
		vc.delegate = self
		vc.allowsEditing = true
		vc.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
		self.presentViewController(vc, animated: true, completion: nil)
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

	// MARK: ImagePickerController Delegate methods

	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		picker.dismissViewControllerAnimated(true) { () -> Void in
			self.capturedImage.image = image
			self.images.append(image)
		}
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		picker.dismissViewControllerAnimated(true, completion: nil)
	}

	// MARK: private helper functions

	private func clearImages() {
		capturedImage.image = nil
		images = []
	}

	func removeInstructions(timer: NSTimer? = nil) {
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.instructionsLabel.alpha = 0.4
			}) { (success) -> Void in
				self.instructionsLabel.removeFromSuperview()
		}
	}

	// MARK: Motion event recognizers

	override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
		if motion == UIEventSubtype.MotionShake {
			UIView.animateWithDuration(0.3, animations: { () -> Void in
				self.capturedImage.alpha = 0
				self.instructionsLabel.alpha = 0
				}, completion: { (success) -> Void in
					if success {
						// reset the alpha of the captured image
						self.capturedImage.alpha = 1
						self.instructionsLabel.alpha = 1
						self.clearImages()
					}
			})
		}
	}
	// MARK: Gesture Recognizers

	func tapViewFinder(sender: UITapGestureRecognizer) {
		takePhoto { (image, error) -> Void in
			if error == nil {
				if let _image = image {
					self.capturedImage.image = _image
					UIView.animateWithDuration(0.2, animations: { () -> Void in
						self.capturedImage.transform = CGAffineTransformMakeScale(1.1, 1.25)
						}, completion: { (success) -> Void in
							if success {
								UIView.animateWithDuration(0.2, animations: { () -> Void in
									self.capturedImage.transform = CGAffineTransformMakeScale(1/1.1, 1/1.1)
								})
							}
					})
					self.images.append(_image)
				}
			}
		}
	}

	// MARK: Segue functions

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "tagImageSegue" {
			let nextVC = segue.destinationViewController as! TaggingImagesViewController
			nextVC.images = self.images
		}
	}

	@IBAction func upload(sender: AnyObject) {
		if images.isEmpty {
			// default to have at least one picture if no images exist
			takePhoto { (image, error) -> Void in
				if (error == nil) {
					self.images.append(image!)
					self.performSegueWithIdentifier("tagImageSegue", sender: nil)
				}
			}
		} else {
			performSegueWithIdentifier("tagImageSegue", sender: nil)
		}
	}

	// unwind segue to clear the images
	@IBAction func resetController(segue: UIStoryboardSegue) {
		// clear the images
		clearImages()
	}
}
