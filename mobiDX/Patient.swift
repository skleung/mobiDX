//
//  Patient.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//

import Foundation
import CoreData


class Patient: NSManagedObject {

	class func createPatientFromParse(user: PFUser, inManagedObjectContext context: NSManagedObjectContext) -> Patient? {
		let request = NSFetchRequest(entityName: "Patient")
		let objId = user.objectId!
		request.predicate = NSPredicate(format: "id = %@", objId)
		if let patient = (try? context.executeFetchRequest(request))?.first as? Patient {
			// if the object is already found, that means it's been reviewed...
			return patient
		} else if let patient = NSEntityDescription.insertNewObjectForEntityForName("Patient", inManagedObjectContext: context) as? Patient {
			patient.id = objId
			patient.first_name = user["first_name"] as? String
			patient.last_name = user["last_name"] as? String
			patient.gender = user["gender"] as? String
			patient.age = user["age"] as? Int
			patient.email = user["email"] as? String
			patient.phone = user["phone"] as? String
			patient.treating = false
			return patient
		}
		return nil
	}
	
}
