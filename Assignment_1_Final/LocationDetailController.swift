//
//  LocationDetailController.swift
//  Assignment_1_Final
//
//  Created by Mashaal on 8/9/19.
//  Copyright © 2019 Monash. All rights reserved.
//
// code referenced from https://www.appcoda.com/uiscrollview-introduction/
// code referenced from https://stackoverflow.com/questions/24097826/read-and-write-a-string-from-text-file



import UIKit
import MapKit
import CoreData

class LocationDetailController: UIViewController, MKMapViewDelegate {


//    @IBOutlet weak var imageViewer: UIImageView!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let initialLocation = CLLocation(latitude: -37.813597, longitude: 144.962014)
    let regionRadius: CLLocationDistance = 15000
    
    //Variable declarations
    var scrollView: UIScrollView!
    var manObj: NSManagedObjectContext
    var filterLocList = [HistPlace]()
    var recdFromLocation: String?
    var recdFromLocationTable: String?
    var sendToEdit: String?
    var titler: String?
    var desc: String?
    var lat: Double?
    var long: Double?
    var detailList = [HistPlace]()
    var histPlaceObj: HistPlace?

    
    //Initialisation
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        manObj = (appDelegate?.persistentContainer.viewContext)!
        
        super.init(coder: aDecoder)
    }
    
 
    
    //fetching and displaying details on the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        


        let fetchR = NSFetchRequest<NSManagedObject>(entityName: "HistPlace")
        fetchR.returnsObjectsAsFaults = false
        
        mapView.delegate = self
        centerMapOnLocation(location: initialLocation)
        
        
        do {
            
            let locations = try manObj.fetch(fetchR) as! [HistPlace]
            detailList = locations
        }
        catch
        {
            print(error)
        }
        

        for loc in detailList
        {
            
            if loc.title! == recdFromLocation
            {
                histPlaceObj = loc
                nameLabel.text = loc.title
                sendToEdit = loc.title
                
                descriptionLabel.text = loc.subtitle
                titler = loc.title
                desc = loc.subtitle
                lat = loc.latitude
                long = loc.longitude
                do {
                    if (loc.photo != " "){
                    try imageViewer.image = loadImage(loader: loc.photo!)
                    }
                    
                    else
                    {
                     imageViewer.image = UIImage(named: loc.title!)
                
                    }
                }
                catch let error{
                    print(error)
                }
                
                
            }
            
        }
        // Do any additional setup after loading the view.
        
//        do {
//            if (place.photo != " ")
//            {
//                try
//                    cell.imageView?.image = resizeImage(image: loadImage(loader: place.photo!), targetSize: CGSize(width: 70, height: 70))
//                //                self.resizeImage(image: loadImage(loader: place.photo!), targetSize: CGSize(width: 200, height: 200))
//
//
//            }
//            else
//            {
//                cell.imageView?.image = resizeImage(image: UIImage(named: selectedCell.title!)!, targetSize: CGSize(width: 70, height: 70))
//
//
//            }
//        }
//        catch let error
//        {
//            print(error)
//        }
//
        let artwork = LocationAnnotation(newTitle: titler!, newSubtitle: desc!, lat: lat!, long: long!)
        mapView.addAnnotation(artwork)
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
    
 
    
    // Centering map on a given location
    func centerMapOnLocation(location:CLLocation) {
        let coordianteRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordianteRegion, animated: true)
    }
    

    // For zooming in on the annotation
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        mapView.showAnnotations([annotation], animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        
    }
    
    
    // Segue to Edit Location
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editLocationSegue") {
            // pass data to next view
            let destViewController = segue.destination as! EditLocViewController
            destViewController.recdHistPlaceObj = histPlaceObj
        
    }

    
   
    }

}

