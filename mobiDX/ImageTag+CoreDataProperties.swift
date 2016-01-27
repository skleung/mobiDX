//
//  ImageTag+CoreDataProperties.swift
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

extension ImageTag {

    @NSManaged var image: NSData?
    @NSManaged var tag: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var treating: NSNumber?
    @NSManaged var id: String?
    @NSManaged var patient: Patient?

}
