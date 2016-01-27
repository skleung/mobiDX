//
//  Patient+CoreDataProperties.swift
//  mobiDX
//
//  Created by Sherman Leung on 12/7/15.
//  Copyright © 2015 Sherman Leung. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Patient {

    @NSManaged var first_name: String?
    @NSManaged var last_name: String?
    @NSManaged var age: NSNumber?
    @NSManaged var gender: String?
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var id: String?
    @NSManaged var treating: NSNumber?
    @NSManaged var images: NSSet?

}
