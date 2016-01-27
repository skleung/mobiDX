//
//  ImageTag.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import Foundation
import CoreData


class ImageTag: NSManagedObject {

	class func createImageTagFromParse(obj: PFObject, data: NSData?, inManagedObjectContext context: NSManagedObjectContext) -> ImageTag? {
		let request = NSFetchRequest(entityName: "ImageTag")
		let objId = obj.objectId!
		request.predicate = NSPredicate(format: "id = %@", objId)
		if let imageTag = (try? context.executeFetchRequest(request))?.first as? ImageTag {
			// if the object is already found, that means it's been reviewed...
			return imageTag
		} else if let imageTag = NSEntityDescription.insertNewObjectForEntityForName("ImageTag", inManagedObjectContext: context) as? ImageTag {
			imageTag.id = objId
			if data != nil {
				imageTag.image = data
			}
			imageTag.tag = obj["tag"] as? String
			let geopoint = obj["location"] as? PFGeoPoint
			imageTag.latitude = geopoint?.latitude
			imageTag.longitude = geopoint?.longitude
			imageTag.patient = Patient.createPatientFromParse(obj["patient"] as! PFUser, inManagedObjectContext: context)
			// default the treatment to be false until the physician diagnoses it
			imageTag.treating = false
			return imageTag
		}
		return nil
	}

	func flagImage(inManagedObjectContext context: NSManagedObjectContext) {
		// mark that this image and its associated patient both need to be treated
		self.treating = true
		self.patient!.treating = true
		do {
			try context.save()
		} catch let error {
			print("Core Data Error \(error)")
		}
	}

}
