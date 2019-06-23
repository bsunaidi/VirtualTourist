//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/17/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit
import MapKit

class FlickrAPI: UIViewController {
    
    static func getPhotosURLs(with coordinate: CLLocationCoordinate2D, pageNumber: Int, completion: @escaping ([URL]?, Error?, String?) -> ()) {
        
        let parameters = [
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.BoundingBox: bboxString(for: coordinate),
            FlickrParameterKeys.Page: pageNumber,
            FlickrParameterKeys.PhotosPerPage: FlickrParameterValues.PhotosPerPage,
            ] as [String:Any]
        
        let request = URLRequest(url: getURL(from: parameters))
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completion(nil, error, nil)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                completion(nil, nil, "Your request returned a status code other than 2xx!")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any] else {
                completion(nil, nil, "Cannot parse data from JSON.")
                return
            }
            
            guard let status = result["stat"] as? String, status == "ok" else {
                completion(nil, nil, "Flickr API returned an error code \(result)")
                return
            }
            
            guard let photosDictionary = result["photos"] as? [String:Any] else {
                completion(nil, nil, "The key 'photos' is not found in \(result)")
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String:Any]] else {
                completion(nil, nil, "The key 'photo' is not found in \(photosDictionary)")
                return
            }
            
            var photosURLs = [URL]()
            for photoDictionary in photosArray {
                guard let urlString = photoDictionary["url_m"] as? String else { continue }
                let url = URL(string: urlString)
                photosURLs.append(url!)
            }
            
            completion(photosURLs, nil, nil)
        }
        
        task.resume()
    }
    
    static func bboxString(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let value = 0.5
        let minLongitude = max(longitude - value, -180)
        let minLatitude = max(latitude - value, -90)
        let maxLongitude = min(longitude + value, 180)
        let maxLatitude = min(latitude + value, 90)
        
        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    static func getURL(from parameters: [String:Any]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
