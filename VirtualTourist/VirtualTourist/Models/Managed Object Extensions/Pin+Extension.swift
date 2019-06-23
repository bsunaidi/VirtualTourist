//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/22/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Pin {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    var coordinates: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get { return CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
    }
    
    func checkEquivalenceCoordinates (coordinate: CLLocationCoordinate2D) -> Bool {
        return (latitude == coordinate.latitude && longitude == coordinate.longitude)
    }
    
}
