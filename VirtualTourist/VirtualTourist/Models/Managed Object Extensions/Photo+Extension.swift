//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/21/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        publicationDate = Date()
    }
    
    func set(image: UIImage) {
        self.imageData = image.pngData()
    }
    
    func getImage() -> UIImage? {
        return (imageData == nil) ? nil : UIImage(data: imageData!)
    }
    
}
