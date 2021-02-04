//
//  MapTabViewController.swift
//  OnTheMap
//
//  Created by Neri Quiroz on 11/22/20.
//

import Foundation
import UIKit
import MapKit

class MapTabViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var locations = [StudentsLocations]()
    var annotations = [MKPointAnnotation]()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 
        loadingIndicator.isHidden = true 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getStudentsPins()
    }
    
    // MARK: Logout
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.loadingIndicator.startAnimating()
        UdacityClient.logout {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Refresh map
    
    @IBAction func refreshMap(_ sender: UIBarButtonItem) {
        getStudentsPins()
    }
    
    // MARK: Add map annotations
    
    func getStudentsPins() {
        self.loadingIndicator.startAnimating()
        UdacityClient.getStudentLocations() { locations, error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Failed network request", preferredStyle: .alert )
                alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in return
                                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.mapView.removeAnnotations(self.annotations)
            self.annotations.removeAll()
            self.locations = locations ?? []
            if locations == nil{
                let alert = UIAlertController(title: "Error", message: "Error loading locations", preferredStyle: .alert )
                alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
                    return
                }))
                self.present(alert, animated: true, completion: nil)
                    return
            } else{
            for dictionary in locations ?? [] {
                let lat = CLLocationDegrees(dictionary.latitude ?? 0.0)
                let long = CLLocationDegrees(dictionary.longitude ?? 0.0)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let first = dictionary.firstName
                let last = dictionary.lastName
                let mediaURL = dictionary.mediaURL
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(first) \(last)"
                annotation.subtitle = mediaURL
                self.annotations.append(annotation)
            }
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.annotations)
                self.loadingIndicator.stopAnimating()
            }
        }
      }
    }
      
    
    // MARK: Map view data source
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle {
                openLink(toOpen ?? "")
            }
        }
    }
    
}
