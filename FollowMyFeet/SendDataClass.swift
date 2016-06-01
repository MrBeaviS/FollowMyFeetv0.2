//
//  SendDataClass.swift
//  FollowMyFeet
//
//  Created by Nicholas Judd on 31/05/2016.
//  Copyright © 2016 Michael Beavis. All rights reserved.
//

import Foundation

class SendDataClass: NSObject {
    var longitude: NSNumber?
    var latitude: NSNumber?
    var longDelta: NSNumber?
    var latDelta: NSNumber?
    var name: String?
    var info: String?
    var dateCreated: NSDate?
    
    init (location: Location) {
        longitude = location.longitude
        latitude = location.latitude
        longDelta = location.longDelta
        latDelta = location.latDelta
        name = location.name
        info = location.info
        dateCreated = location.dateCreated
    }
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeObject(longitude, forKey: "longitude")
        aCoder.encodeObject(latitude, forKey: "latitude")
        aCoder.encodeObject(longDelta, forKey: "longDelta")
        aCoder.encodeObject(latDelta, forKey: "latDelta")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(info, forKey: "info")
        aCoder.encodeObject(dateCreated, forKey: "dateCreated")
    }
    
    init (coder aDecoder: NSCoder!) {
        if let longitude = aDecoder.decodeObjectForKey("longitude") as? NSNumber {
            self.longitude = longitude
        }
        if let latitude = aDecoder.decodeObjectForKey("latitude") as? NSNumber {
            self.latitude = latitude
        }
        if let longDelta = aDecoder.decodeObjectForKey("longDelta") as? NSNumber {
            self.longDelta = longDelta
        }
        if let latDelta = aDecoder.decodeObjectForKey("latDelta") as? NSNumber {
            self.latDelta = latDelta
        }
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
        if let info = aDecoder.decodeObjectForKey("info") as? String {
            self.info = info
        }
        if let dateCreated = aDecoder.decodeObjectForKey("dateCreated") as? NSDate {
            self.dateCreated = dateCreated
        }
        
    }
}