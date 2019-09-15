//
//  EditLocViewController.swift
//  Assignment_1_Final
//
//  Created by Mashaal on 10/9/19.
//  Copyright © 2019 Monash. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class EditLocViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var recdHistPlaceObj: HistPlace?
    var histObj2: HistPlace?
    
    @IBOutlet weak var nameLbl: UITextField!
    @IBOutlet weak var descLbl: UITextField!
    @IBOutlet weak var mpView: MKMapView!
    @IBOutlet weak var imgView: UIImageView!
    var manObj: NSManagedObjectContext
    var histPlaceLatitude: Double?
    var histPlaceLongitude: Double?
    let regionRadius: CLLocationDistance = 1000
    var locationManager: CLLocationManager = CLLocationManager()
    var imagePicker: UIImagePickerController = UIImagePickerController()
    var locList = [HistPlace]()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        manObj = ((appDelegate?.persistentContainer.viewContext)!)
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        imagePicker.delegate = self
        
        let rightBarButton = UIBarButtonItem(title: "Save", style: UIBarButtonItem.Style.plain, target: self, action: #selector(EditLocViewController.myRightSideBarButtonItemTapped(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(NewLocationViewController.handleTap(_:)))
        self.mpView.addGestureRecognizer(tapGesture)
        
        if recdHistPlaceObj != nil
        {
            nameLbl.placeholder = recdHistPlaceObj?.title
            descLbl.placeholder = recdHistPlaceObj?.subtitle
            
            
            
            
            
            
            let artwork = LocationAnnotation(newTitle: recdHistPlaceObj!.title!, newSubtitle: recdHistPlaceObj!.subtitle!, lat: recdHistPlaceObj!.latitude, long: recdHistPlaceObj!.longitude)
            
            mpView.addAnnotation(artwork)
            
        }
        
        
        func centerMapOnLocation(location:CLLocation) {
            let coordianteRegion = MKCoordinateRegion(center: location.coordinate,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mpView.setRegion(coordianteRegion, animated: true)
        }
        
        
      


        // Do any additional setup after loading the view.
    }
    
    func writeToFilePath() -> String
    {
        let timeStamper = UInt(Date().timeIntervalSince1970)
        var pData = Data()
        if imgView?.image == nil
        {
            let alertController = UIAlertController(title: "No Picture has been picked!", message: "Please select a photo", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        }
        else
        {
        pData = (imgView.image?.jpegData(compressionQuality: 1.0)!)!
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) [0] as String
        let URL = NSURL(fileURLWithPath: path)
        if let pathComp = URL.appendingPathComponent("\(timeStamper)")
        {
            let filePath = pathComp.path
            let fileMgr = FileManager.default
            fileMgr.createFile(atPath: filePath, contents: pData, attributes: nil)
        }
        }
        return String(timeStamper)
    }
    
    
    
    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem!)
    {
        
        
        
        do{
            
        if recdHistPlaceObj != nil{
            
            histObj2 = recdHistPlaceObj
            //let deletefilter = locList.remove(at: )
                manObj.delete(histObj2!)
        }
        
        try manObj.save()
            
        }
        catch let error as NSError {
            
            print("Couldn't delete unfortunately")
        }
        //let deletefilter = locList.remove()
        
        //tableView.deleteRows(at: [indexPath], with: .fade)
        
        let place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj) as! HistPlace
        
        place.photo = writeToFilePath()
        
        if let text = nameLbl.text, !text.isEmpty
        {
            //do something if it's not empty
            place.title = nameLbl.text!
        }
        else
        {
            let alertController = UIAlertController(title: "Name Text Field is empty", message: "Please enter a valid name of the location", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        if let text = descLbl.text, !text.isEmpty
        {
            //do something if it's not empty
            place.subtitle = descLbl.text!
        }
        else
        {
            let alertController = UIAlertController(title: "Description Text Field is empty", message: "Please enter a valid description of the location", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        if (histPlaceLatitude != nil) || (histPlaceLongitude != nil)
        {
            
            place.latitude = histPlaceLatitude!
            place.longitude = histPlaceLongitude!
        }
        else
        {
            let alertController = UIAlertController(title: "No Location has been chosen!", message: "Please place a marker for the new location", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
    
        do
        {
            try manObj.save()
        }
        catch {
            print("Big boi errrorr")
        }
        
        
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func capPhoto(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imgView.image = selectedImage
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    func focusOn(annotation: MKAnnotation) {
        mpView.selectAnnotation(annotation, animated: true)
        mpView.showAnnotations([annotation], animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
        mpView.setRegion(mpView.regionThatFits(zoomRegion), animated: true)
        
        
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.ended {
            
            let touchPoint = sender.location(in: mpView)
            let touchCoordinate = mpView.convert(touchPoint, toCoordinateFrom: mpView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Historical Location"
            histPlaceLatitude = annotation.coordinate.latitude
            histPlaceLongitude = annotation.coordinate.longitude
            mpView.removeAnnotations(mpView.annotations)
            mpView.addAnnotation(annotation) //drops the pin
            
            var locForReverse = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(locForReverse, completionHandler: {(placemarks, error) -> Void in
                
                
                if error != nil {
                    print("Reverse geocoder failed with error")
                    return
                }
                
                if placemarks!.count > 0 {
                    let placer = placemarks![0]
                    annotation.title = "\((placer.name)!)"
                    if placer.locality != nil
                    {
                    annotation.subtitle = "\(placer.locality!)"
                    }
                    else
                    {
                        let alert = UIAlertController(title: "Please select a valid location", message: "Only land areas are valid locations", preferredStyle:
                            UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style:
                            UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
                
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
