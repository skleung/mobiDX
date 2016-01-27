//
//  PatientsViewController.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import UIKit
import CoreData

class PatientsViewController: UITableViewController {

	var patients:[Patient] = []

	override func viewDidLoad() {
		tableView.delegate = self
		fetchPatients()
	}

	override func viewWillAppear(animated: Bool) {
		fetchPatients()
	}

	func fetchPatients() {
		let context = AppDelegate.managedObjectContext
		let request = NSFetchRequest(entityName: "Patient")
		request.predicate = NSPredicate(format: "treating = %@", true)
		request.sortDescriptors = [NSSortDescriptor(key: "last_name", ascending: true)]
		if let _ = context {
			if let patients = (try? context!.executeFetchRequest(request)) as? [Patient] {
				self.patients = patients
				tableView.reloadData()
			}
		}
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return patients.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserCell
		cell.patient = patients[indexPath.row]
		cell.setupCell()
		return cell
	}

	override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 96
	}

	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let emailAction = UITableViewRowAction(style: .Normal, title: "Email") { (_, indexPath) -> Void in
			let p = self.patients[indexPath.row]
			let url = NSURL(string: "mailto:\(p.email!)")
			UIApplication.sharedApplication().openURL(url!)
		}
		emailAction.backgroundColor = view.tintColor
		let callAction = UITableViewRowAction(style: .Normal, title: "Call") { (_, indexPath) -> Void in
			let p = self.patients[indexPath.row]
			UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(p.phone!)")!)
		}
		return [emailAction, callAction]
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		performSegueWithIdentifier("showImages", sender: indexPath)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showImages" {
			if let i = sender as? NSIndexPath {
				let images = self.patients[i.row].images
				let imagesVC = segue.destinationViewController as! ImagesViewController
				imagesVC.images = (images?.allObjects as? [ImageTag]) ?? []
			}
		}
	}
}
