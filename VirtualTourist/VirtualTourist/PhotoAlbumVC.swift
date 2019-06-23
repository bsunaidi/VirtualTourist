//
//  PhotoAlbumVC.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/21/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var pin: Pin!
    var context: NSManagedObjectContext { return DataController.shared.viewContext }
    var areTherePhotos: Bool { return (fetchedResultsController.fetchedObjects?.count ?? 0) != 0 }
    var isDeletingAll = false
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pin.coordinates
        self.noImagesLabel.isHidden = true
        updateUI(processing: false)
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func fetch() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "publicationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", pin)
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            areTherePhotos ? updateUI(processing: false) : newCollectionPressed(self)
        } catch {
            fatalError("The fetch could not be performd: \(error.localizedDescription)")
        }
    }
    
    func updateUI(processing: Bool) {
        collectionView.isUserInteractionEnabled = !processing
        if processing {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            newCollectionButton.title = ""
            
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            newCollectionButton.title = "New Collection"
        }
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        updateUI(processing: true)
        
        if areTherePhotos {
            isDeletingAll = true
            for photo in fetchedResultsController.fetchedObjects! {
                context.delete(photo)
            }
            try? context.save()
            isDeletingAll = false
        }
        
        FlickrAPI.getPhotosURLs(with: pin.coordinates, pageNumber: pageNumber) { (urls, error, errorMessage) in
            DispatchQueue.main.async {
                self.updateUI(processing: false)
                
                guard (error == nil) && (errorMessage == nil) else {
                    self.alert(title: "Error", message: error?.localizedDescription ?? errorMessage!)
                    return
                }
                
                guard let urls = urls, !urls.isEmpty else {
                    self.noImagesLabel.isHidden = false
                    return
                }
                
                for url in urls {
                    let photo = Photo(context: self.context)
                    photo.imageURL = url
                    photo.pin = self.pin
                }
                
                try? self.context.save()
            }
        }
        pageNumber += 1
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        let photo = fetchedResultsController.object(at: indexPath)
        cell.imageView.setPhoto(photo)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        context.delete(photo)
        try? context.save()
    }
    
    // MARK: photosFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, type == .delete && !isDeletingAll {
            collectionView.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert {
            collectionView.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            collectionView.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            collectionView.reloadData()
        }
    }
    
}
