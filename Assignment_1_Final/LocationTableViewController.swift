//
//  LocationTableViewController.swift
//  Assignment_1_Final
//
//  Created by Mashaal on 1/9/19.
//  Copyright © 2019 Monash. All rights reserved.
//
// code referenced from https://www.raywenderlich.com/472-uisearchcontroller-tutorial-getting-started
// code referenced from https://stackoverflow.com/questions/37344822/saving-image-and-then-loading-it-in-swift-ios
// code referecned from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
// code referenced from https://stackoverflow.com/questions/24097826/read-and-write-a-string-from-text-file




import UIKit
import MapKit
import CoreData
import UserNotifications



class LocationTableViewController: UITableViewController, CLLocationManagerDelegate, NewLocationDelegate {
    
    // variable declarations
    var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()
    var locList = [HistPlace]()
    var filterLocList = [HistPlace]()
    var locationManager = CLLocationManager()
    var manObj: NSManagedObjectContext
    var centerCoord: CLLocationCoordinate2D?
    var locationDetailController: LocationDetailController?
    var imageName: [String]!
    var sendPhoto: String?
    let defPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    
    
    // initialision
    required init?(coder aDecoder: NSCoder) {
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        manObj = (appDelegate?.persistentContainer.viewContext)!
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
    
        
        self.navigationController?.navigationBar.barTintColor  = UIColor.yellow;
        navigationController?.navigationBar.tintColor = UIColor.black
        

        
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.reloadData()
        
        // introducing the search controller in the UI
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Locations or sort via the right btn"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        searchController.searchBar.delegate = self
        searchController.searchBar.showsSearchResultsButton = true
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(named: "Sort"), for: .bookmark, state: .normal)
        searchController.searchBar.scopeButtonTitles = ["A-Z", "Z-A"]
        
        // fetching from the database
        let fetchR = NSFetchRequest<NSManagedObject>(entityName: "HistPlace")
        fetchR.returnsObjectsAsFaults = false
    
        // This do catch implements the initial locations in the app
        do {
            
            let locations = try manObj.fetch(fetchR) as! [HistPlace]
            
             if locations.count == 0
            {
                starterData()
                let freshLocations = try manObj.fetch(fetchR) as! [HistPlace]
                locList = freshLocations

            
            }
            else
            {

                    locList = locations
            }

        }
        catch
        {
            print(error)
        }
        
        filterLocList = locList
        
        manipulateAnnotations()
        
        // for notifications in the background
        let auth = UNUserNotificationCenter.current()
        auth.requestAuthorization(options: [.alert,.badge,.sound]){
            (granted, error) in
            if granted
            {
               print("Thank you!")
            }
            else
            {
                print("Please accept the notifications request")
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
   
        }
    
    
    //Initialising the starter data for the Location list
    func starterData()
    {
        do{
        var place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj) as! HistPlace
    //1st Location
        place.title = "Melbourne CBD Flinders Street"
        place.subtitle = "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations. Take a train for outer-Melbourne explorations, join a tour to learn more about the history of the grand building, or go underneath the station to see the changing exhibitions that line Campbell Arcade."
        place.latitude = -37.8183
        place.longitude = 144.9671
        place.photo = " "
        var imagePath = defPath.appendingPathComponent(place.title! + ".jpeg")
        try #imageLiteral(resourceName: "Como house & garden").jpegData(compressionQuality: 1.0)?.write(to: imagePath)
        
     //2nd Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "St Pauls Cathedral"
        place.subtitle = "Leave the bustling Flinders Street Station intersection behind and enter the peaceful place of worship that's been at the heart of city life since the mid 1800s. Join a tour and admire the magnificent organ, the Persian Tile and the Five Pointed Star of the historic St Paul's Cathedral."
        place.latitude = -37.8170
        place.longitude = 144.9677
        place.photo = " "

            
        //3rd Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Royal Heritage Building"
        place.subtitle = " The building is one of the world's oldest remaining exhibition pavilions and was originally built for the Great Exhibition of 1880. Later it housed the first Commonwealth Parliament from 1901, and was the first building in Australia to achieve a World Heritage listing in 2004. "
        place.latitude = -37.8047
        place.longitude = 144.9717
        place.photo = " "
        
        //4th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Rippon Lea Estate"
        place.subtitle = "An intact example of 19th century suburban high life, the National Heritage Listed Rippon Lea Estate is like a suburb all to itself, an authentic Victorian mansion amidst 14 acres of breathtaking gardens."
        place.latitude = -37.5245
        place.longitude = 144.5820
        place.photo = " "
        
        //5th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Como house & garden"
        place.subtitle = "Built in 1847, Como House and Garden is one of Melbourne most glamorous stately homes. A unique blend of Australian Regency and classic Italianate architecture, Como House offers a rare glimpse into the opulent lifestyles of former owners, the Armytage family, who lived there for over a century."
        place.latitude = -37.5017
        place.longitude = 145.0013
        place.photo = " "
        
        //6th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Werribee Park & Mansion"
        place.subtitle =
        "Enjoy a perfect day out at Werribee Park. Experience the grandeur of Werribee Mansion, discover Victoria's unique pastoral history down at the farm and homestead, relax with family and friends on the Great lawn surrounded by stunning formal gardens, and so much more."
        place.latitude = -37.9301
        place.longitude = 144.6690
        place.photo = " "
        
        //7th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Altona Homestead"
        place.subtitle = "Built in the mid-1840s by Alfred and Sarah Langhorne, Altona Homestead was the first homestead built on the foreshore of Port Phillip Bay. Remaining a private residence until 1920, the homestead changed ownership a number of times and served as a seaside holiday village, Council offices, meeting place for community groups and even a dentist."

        place.latitude = -37.8694
        place.longitude = 144.8293
        place.photo = " "
        
        //8th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "The Scots' Church"
        place.subtitle = "Look up to admire the 120-foot spire of the historic Scots' Church, once the highest point of the city skyline. Nestled between modern buildings on Russell and Collins streets, the decorated Gothic architecture and stonework is an impressive sight, as is the interior's timber panelling and stained glass. Trivia buffs, take note: the church was built by David Mitchell, father of Dame Nellie Melba (once a church chorister)."
        place.latitude = -37.4851
        place.longitude = 144.5806
        place.photo = " "
        
        //9th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "LaBassa Mansion"
        place.subtitle = "Labassa is one of Australia's most outstanding 19th century mansions.Designed by architect John Augustus Bernard Koch for millionaire Alexander Robertson, the house is thirty-five roomed property with ornate interiors in the French Second Empire style."
        place.latitude = -37.4903
        place.longitude = 144.5745
        place.photo = " "
        
        
        //10th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Royal Botanic Gardens Victoria"
        place.subtitle = "Just a 45 minute drive from Melbourne's city centre, discover the astonishing beauty and diversity of more than 170,000 individual native plants at the Cranbourne Gardens. You will find them displayed in settings that capture the essence of Australia's diverse landscape from the Red Centre to the coastal fringes."
        place.latitude = -37.4948
        place.longitude = 144.5846
        place.photo = " "
        
        //11th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "ICI House"
        place.subtitle = "At the top of the city grid sits one of the most seminal pieces of Melbourne design, the former ICI House (now Orica Headquarters). This is a quintessential piece of post-war modernism – finished in 1957 and designed by Bates Smart & McCutcheon, Australia's oldest design practice."
        place.latitude = -37.4831
        place.longitude = 144.5824
        place.photo = " "
        
        //12th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Sidney Myer Music Bowl"
        place.subtitle = "Across the river from Flinders Street Station, inside the Domain, you will find the magnificent Sidney Myer Music Bowl. Home to many great events, it opened in 1959 and was designed by Yuncken Freeman Architects. Marvelling at its modern look,The Herald called the Music Bowl 'the most startling architectural piece ever seen in Melbourne'. The tensile cable structure spans between the ground and two graceful, billowing columns, using the ground to form an auditorium (some say its aerodynamic shape was inspired by Louis Armstrong's trumpet). The facility was carefully restored and upgraded by architect Greg Burgess a few years ago."

        place.latitude = -37.8233
        place.longitude = 144.9747
        place.photo = " "
        
        
        //13th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Melbourne Cricket Ground"
        place.subtitle = "Back across the Yarra toward Richmond is the sports mecca of Melbourne Park, home also to the MCG. The 1956 Olympic Pool is a superb piece of balanced engineering and architecture, and from the same period of experimentation as the Myer Music Bowl. It is now the training and function centre of the Collingwood Football Club. "
        place.latitude = -37.4919
        place.longitude = 144.5859
        place.photo = " "
        
        //14th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "The Ian Potter Centre"
        place.subtitle = "The Ian Potter Centre: NGV Australia at Federation Square is the home of Australian art with superb collections of Australian Indigenous and non-Indigenous art from the Colonial period to the present day. With more Australian art on permanent display than any other gallery in the world, as well as special exhibitions and programs, cafes, a restaurant and new perspectives of the city through its glass matrix, NGV Australia is more than a great place to view art."
        place.latitude = -37.4900
        place.longitude = 144.5811
        place.photo = " "
        
        //15th Location
        place = NSEntityDescription.insertNewObject(forEntityName: "HistPlace", into: manObj)
            as! HistPlace
        place.title = "Heide Museum of Modern Art"
        place.subtitle = " Heide Museum of Modern Art, or Heide as it is affectionately known, began life in 1934 as the Melbourne home of John and Sunday Reed and has since evolved into one of Australia's most unique destinations for modern and contemporary Australian art. Located just twenty minutes from the city, Heide boasts fifteen acres of beautiful gardens, three dedicated exhibition spaces, two historic kitchen gardens, a sculpture park and the Heide Store."
        place.latitude = -37.4531
        place.longitude = 145.0503
        place.photo = " "
            
            try manObj.save()
        }
        catch {
            print(error)
        }
        
        
       

    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScope: Int) {
        print("New scope index is now \(selectedScope)")
    }
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    //filtering the content for search
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filterLocList = locList.filter({( location : HistPlace) -> Bool in
            return (location.title!.contains(searchText))
        })
        
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        


        // fetching and displaying the list
        let fetchR = NSFetchRequest<NSManagedObject>(entityName: "HistPlace")
        
        do
        {
            let locations = try manObj.fetch(fetchR) as! [HistPlace]
            
            filterLocList = locations
            locList = locations
            

            manipulateAnnotations()
            
        }
        catch
        {
            print(error)
        }
        
        self.tableView.reloadData()
      
        
    }
    
    
    // Geofence and notifier on exit
    func locationManager(_ manager: CLLocationManager, didExitRegion region:
        CLRegion) {
        let alert = UIAlertController(title: "Movement Detected!", message: "You have left!",
        preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
                 bgNotifier(movement: "You have exited\(region.identifier) place", identifier: "Identified Exit")
    }

    
    func locationAnnotationAdded(annotation: LocationAnnotation)
    {
        locationList.append(annotation)
        mapViewController?.mapView.addAnnotation(annotation)
        locationDetailController?.mapView.addAnnotation(annotation)

   tableView.insertRows(at: [IndexPath(row: locationList.count - 1, section: 0)], with: .automatic)
    }

   
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering() {
            return filterLocList.count
        }
        
        return locList.count
    }
    

    //display photo and location
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
            
            let selectedCell = self.locList[indexPath.row]
            sendPhoto = selectedCell.title!
            var location: HistPlace
            
            if isFiltering() {
                location = filterLocList[indexPath.row]
            } else {
                location = locList[indexPath.row]
            }
            
            let place: HistPlace
            place = selectedCell
            do {
            if (place.photo != " ")
            {
                try
                cell.imageView?.image = resizeImage(image: loadImage(loader: place.photo!), targetSize: CGSize(width: 70, height: 70))
//                self.resizeImage(image: loadImage(loader: place.photo!), targetSize: CGSize(width: 200, height: 200))


                }
            else
            {
            cell.imageView?.image = resizeImage(image: UIImage(named: selectedCell.title!)!, targetSize: CGSize(width: 70, height: 70))
        
            
            }
            }
            catch let error
            {
                print(error)
            }
            
            cell.textLabel?.text = selectedCell.title
            cell.textLabel?.textColor = UIColor.white

            
            cell.detailTextLabel?.text = selectedCell.subtitle
            cell.detailTextLabel!.textColor = UIColor.white
            return cell
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
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    override func tableView(_ tableView:UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let histPlace: HistPlace
        histPlace = self.locList[indexPath.row]
        let annotation = LocationAnnotation(newTitle: histPlace.title!, newSubtitle: histPlace.subtitle!, lat: histPlace.latitude, long: histPlace.longitude)
        mapViewController?.focusOn(annotation: annotation)
        locationDetailController?.focusOn(annotation: annotation)
        
        
        
    }
    
 
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete
        {
            let deletefilter = locList.remove(at: indexPath.row)
            manObj.delete(deletefilter)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            
            manipulateAnnotations()
            
            do {
                try manObj.save()
            } catch let error as NSError {
                print("Couldn't delete unfortunately")
            }
            
        }
        self.tableView.reloadData()
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addLocationSegue":
            let controller = segue.destination as! NewLocationViewController
        case "showLocationDetails":
            let controller1 = segue.destination as! MapViewController
            controller1.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller1.navigationItem.leftItemsSupplementBackButton = true
            
            
        default: break
            
        }
        
    }
    
    
        func manipulateAnnotations()
    {
            self.mapViewController?.mapView.removeAnnotations((mapViewController?.mapView.annotations)!)
        
        
            for geo in locationManager.monitoredRegions
            {
                locationManager.stopMonitoring(for: geo)
            }
        
        
            for loc in filterLocList
            {
                
                let location: LocationAnnotation = LocationAnnotation(newTitle: loc.title!, newSubtitle: loc.subtitle!, lat: loc.latitude, long:loc.longitude)
                
            
                
                mapViewController?.mapView.addAnnotation(location)
                locationDetailController?.mapView.addAnnotation(location)
                var geoLocation = CLCircularRegion()
                centerCoord = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                geoLocation = CLCircularRegion(center: centerCoord!, radius: 1000, identifier: loc.title!)
                geoLocation.notifyOnEntry = true
                geoLocation.notifyOnExit = true
    
                
                locationManager.delegate = self
                locationManager.requestAlwaysAuthorization()
                locationManager.startMonitoring(for: geoLocation)
                
            }
            
            
        }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapViewController?.mapView.showsUserLocation = (status == .authorizedAlways)
        locationDetailController?.mapView.showsUserLocation = (status == .authorizedAlways)
        
    }
        
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion)
        {
            let alert = UIAlertController(title: "Movement Detected!", message: "You have entered the region!", preferredStyle:
                UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style:
                UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
           print("hello!")
            
         bgNotifier(movement: "You have entered\(region.identifier) place", identifier: "Identified Entry")
            
            
        }
    
    func bgNotifier(movement: String, identifier: String)
    {
        let notifier = UNMutableNotificationContent()
        notifier.title = "Detected change in movement "
        notifier.body = movement
        notifier.sound = UNNotificationSound.default
        let provoker = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let provokeReceiver = UNNotificationRequest (identifier: identifier, content: notifier, trigger: provoker)
        UNUserNotificationCenter.current().add(provokeReceiver, withCompletionHandler: nil)
        
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 40
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationTableViewController: UISearchResultsUpdating
{
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
  // TODO
        
        filterContentForSearchText(searchController.searchBar.text!)
}

}

extension LocationTableViewController: UISearchBarDelegate{
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
       
            
          locList.sort(by: {$0.title! < $1.title!})
            tableView.reloadData()
        }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        tableView.reloadData()
    }
    
    }


