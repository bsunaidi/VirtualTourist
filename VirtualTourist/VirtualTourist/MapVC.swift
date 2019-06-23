//
//  MapVC.swift
//  VirtualTourist
//
//  Created by Bushra AlSunaidi on 6/21/19.
//  Copyright © 2019 Bushra. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var context: NSManagedObjectContext {
        return DataController.shared.viewContext
    }
    
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func fetch() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            updateMapView()
        } catch {
            fatalError("The fetch could not be performd: \(error.localizedDescription)")
        }
    }
    
    func updateMapView() {
        guard let createdPins = fetchedResultsController.fetchedObjects else { return }
        
        for pin in createdPins {
            if mapView.annotations.contains(where: { pin.checkEquivalenceCoordinates(coordinate: $0.coordinate) }) { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinates
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func createNewPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began { return }
        let touchPoint = sender.location(in: mapView)
        let pin = Pin(context: context)
        pin.coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        try? context.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoAlbum" {
            let PhotoAlbumVC = segue.destination as! PhotoAlbumVC
            PhotoAlbumVC.pin = sender as? Pin
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let pin = fetchedResultsController.fetchedObjects?.filter {
            $0.checkEquivalenceCoordinates(coordinate: view.annotation!.coordinate)
            }.first!
        performSegue(withIdentifier: "ShowPhotoAlbum", sender: pin)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateMapView()
    }
    
}
