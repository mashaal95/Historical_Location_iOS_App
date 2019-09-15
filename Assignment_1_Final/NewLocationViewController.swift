//
//  NewLocationViewController.swift
//  Assignment_1_Final
//
//  Created by Mashaal on 1/9/19.
//  Copyright © 2019 Monash. All rights reserved.
//
// code referenced from https://stackoverflow.com/questions/40844336/create-long-press-gesture-recognizer-with-annotation-pin
// code referenced from https://stackoverflow.com/questions/46869394/reverse-geocoding-in-swift-4
//code referenced from https://theswiftdev.com/2019/01/30/picking-images-with-uiimagepickercontroller-in-swift-5/
// code referecned from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift



//
import UIKit
import MapKit
import CoreData

protocol NewLocationDelegate {
    
}

class NewLocationViewController: UIViewController, CLLocationManagerDelegate, NewLocationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var mapViewer: MKMapView!
    
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    
    @IBOutlet weak var imageViewer: UIImageView!
    
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var manObj: NSManagedObjectContext
    var histPlaceLatitude: Double?
    var histPlaceLongitude: Double?
    let initialLocation = CLLocation(latitude: -37.813597, longitude: 144.962014)
    let regionRadius: CLLocationDistance = 1000
    
    
    
    
    @IBAction func capture(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker,animated: true, completion: nil)
    }
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(NewLocationViewController.handleTap(_:)))
        self.mapViewer.addGestureRecognizer(tapGesture)
        
        centerMapOnLocation(location: initialLocation)
        
        // self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
        // Do any additional setup after loading the view.
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageViewer.image = selectedImage
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func showImage(_ sender: UIButton) {
        
        
    }
    
    //
    //
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        locationManager.startUpdatingLocation()
    //    }
    
    //    override func viewDidDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        locationManager.stopUpdatingLocation()
    //    }
    //    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    //    {
    //        let location = locations.last!
    //        currentLocation = location.coordinate
    //    }

    
    @IBAction func saveLocation(_ sender: Any) {
        
        
        let place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj) as! HistPlace
        
        place.photo = writeToFilePath()
        
        if let text = nameTextField.text, !text.isEmpty
        {
            //do something if it's not empty
            place.title = nameTextField.text!
        }
        else
        {
            let alertController = UIAlertController(title: "Name Text Field is empty", message: "Please enter a valid name of the location", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        if let text = descriptionTextField.text, !text.isEmpty
        {
            //do something if it's not empty
            place.subtitle = descriptionTextField.text!
        }
        else
        {
            let alertController = UIAlertController(title: "Description Text Field is empty", message: "Please enter a valid description of the location", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
        
        //place.subtitle = descriptionTextField.text!
        
        if (histPlaceLatitude != nil) && (histPlaceLongitude != nil)
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
    
        
        //        let img = UIImage() //Change to be from UIPicker
        //        let data = UIImagePNGRepresentation(imagePicker)
        //        UserDefaults.standardUserDefaults().setObject(data, forKey: "myImageKey")
        //        UserDefaults.standard.synchronize()
        //
        //        //Get image
        //        if let imgData = UserDefaults.standardUserDefaults().objectForKey("myImageKey") as? NSData {
        //            let retrievedImg = UIImage(data: imgData)
        //        }//
        do
        {
            try manObj.save()
        }
        catch {
            print("Big boi errrorr")
        }
        
        
        navigationController?.popViewController(animated: true)
    }
    
    func writeToFilePath() -> String
    {
        let timeStamper = UInt(Date().timeIntervalSince1970)
        var pData = Data()
        if imageViewer?.image == nil
        {
            let alertController = UIAlertController(title: "No Picture has been picked!", message: "Please select a photo", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            
        }
        else
        {
        pData = (imageViewer.image?.jpegData(compressionQuality: 1.0)!)!
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
    
    @objc func handleTap(_ sender: UIGestureRecognizer)
    {
        if sender.state == UIGestureRecognizer.State.ended {
            
            let touchPoint = sender.location(in: mapViewer)
            let touchCoordinate = mapViewer.convert(touchPoint, toCoordinateFrom: mapViewer)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = "Historical Location"
            histPlaceLatitude = annotation.coordinate.latitude
            histPlaceLongitude = annotation.coordinate.longitude
            mapViewer.removeAnnotations(mapViewer.annotations)
            mapViewer.addAnnotation(annotation) //drops the pin
            
            var locForReverse = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(locForReverse, completionHandler: {(placemarks, error) -> Void in

                
                if error != nil {
                    print("Reverse geocoder failed with error")
                    return
                }
                
                if placemarks!.count > 0 {
                    let placer = placemarks![0]
                    annotation.title = "\((placer.name)!)"
                    annotation.subtitle = "\(placer.locality!)"
                }
                
                
            })
        }
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
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func centerMapOnLocation(location:CLLocation) {
        let coordianteRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapViewer.setRegion(coordianteRegion, animated: true)
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

extension NewLocationViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        self.imageViewer.image = image
    }
}


