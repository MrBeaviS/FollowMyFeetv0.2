//
//  Path+CoreDataProperties.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 11/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Path {

    @NSManaged var name: String?
    @NSManaged var info: String?
    @NSManaged var location: NSSet?

}
