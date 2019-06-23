//
//  FlickrAPI+Extension.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/22/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import Foundation

extension FlickrAPI {
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PhotosPerPage = "per_page"
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "919158920e04b6b85f5f3ae02265a7cf"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = 12
    }
    
}
