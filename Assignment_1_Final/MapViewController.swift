//
//  MapViewController.swift
//  Assignment_1_Final
//
//  Created by Mashaal on 1/9/19.
//  Copyright © 2019 Monash. All rights reserved.
//
// code referenced from raywenderlich.com/548-mapkit-tutorial-getting-started#toc-anchor-007
// code referecned from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
// code referenced from https://stackoverflow.com/questions/24097826/read-and-write-a-string-from-text-file



import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var sentToLocation: String?
    var manObj: NSManagedObjectContext
    var locList = [HistPlace]()
    
    
    let initialLocation = CLLocation(latitude: -37.813597, longitude: 144.962014)
    let regionRadius: CLLocationDistance = 1000
    
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        manObj = (appDelegate?.persistentContainer.viewContext)!
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        centerMapOnLocation(location: initialLocation)
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(NewLocationViewController.handleTap(_:)))
//        self.mapView.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    

    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        mapView.showAnnotations([annotation], animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        
    }
    
    
    // referenced from https://stackoverflow.com/questions/35705649/how-to-center-a-map-on-user-location-ios-9-swift
    func centerMapOnLocation(location:CLLocation) {
        let coordianteRegion = MKCoordinateRegion(center: location.coordinate,
    latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordianteRegion, animated: true)
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 2
        if annotation is MKUserLocation { return nil }
        // 3
        let identifier = "pt"
        var mv: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation as? MKAnnotation
            mv = dequeuedView
        } else {
            // 5
            mv = MKMarkerAnnotationView(annotation: annotation as? MKAnnotation, reuseIdentifier: identifier)
            mv.canShowCallout = true
            mv.rightCalloutAccessoryView?.tintColor = .black
            mv.rightCalloutAccessoryView?.backgroundColor = .black
            
            var color: UIColor = .purple
            mv.markerTintColor = color
            let fetchR = NSFetchRequest<NSManagedObject>(entityName: "HistPlace")
            fetchR.returnsObjectsAsFaults = false
            
            // This do catch implements the initial locations in the app
            do {
                
                    let freshLocations = try manObj.fetch(fetchR) as! [HistPlace]
                    locList = freshLocations
                
                for loc in locList
                {
                    if loc.title == mv.annotation?.title
                    {
                        if (loc.photo != " "){
                            try mv.leftCalloutAccessoryView = UIImageView(image: resizeImage(image: loadImage(loader: loc.photo!), targetSize: CGSize(width: 70, height: 70)))
                        }
                            
                        else
                        {
                            mv.leftCalloutAccessoryView = UIImageView(image: resizeImage(image: UIImage(named: loc.title!)!, targetSize: CGSize(width: 70, height: 70)))
                            
                        }
                    }
                }
            }
               
            catch
            {
                print(error)
            }
            mv.calloutOffset = CGPoint(x: 0, y: 0)
            mv.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return mv
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            sentToLocation = (view.annotation?.title!)!
            performSegue(withIdentifier: "showLocationDetails", sender: self)
     
        }
        
    }
    
    func loadImage(loader: String) -> UIImage
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let URL = NSURL(fileURLWithPath: path)
        var pic: UIImage?
        if let pComp = URL.appendingPathComponent(loader)
        {
            let filePath = pComp.path
            
            let fileMgr = FileManager.default
            let fileData = fileMgr.contents(atPath: filePath)
            
            pic = UIImage(data: fileData!)
            
        }
        return pic!
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showLocationDetails") {
            // pass data to next view
            let destViewController = segue.destination as! LocationDetailController
            destViewController.recdFromLocation = sentToLocation
            
            
        }
    
    
    }
    
    
}


