//
//  ViewController.swift
//  Virus
//
//  Created by Tommy NG on 1/8/2022.
//

import UIKit
import CoreLocation
import MapKit
import Contacts
import Foundation


class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    @IBOutlet var labeltext: UILabel!
    
    
    struct Places: Decodable {
        let building: String
        let District: String
        let date: String
        
        enum CodingKeys: String, CodingKey {
            case District
            case building = "Building name"
            case date="Last date of visit of the case(s)"
        }
    }
    var url:URL!
    var places = [Places]()
    let decoder = JSONDecoder()
    var position:String = ""
    var runAnimation = true
    var name1:String = ""
    var name2:String = ""
    var name3:String = ""
    

    @IBOutlet var tableView: UITableView!
    
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style:.large)
        activityIndicator.center = self.view.center
        return activityIndicator
    }()
    
    let locationManager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !runAnimation { return }
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
       // var latitudeText:String = "\(locValue.latitude)"
        //var longitudeText:String = "\(locValue.longitude)"
       
        //getAddressFromLatLon(pdblLatitude: latitudeText, withLongitude: longitudeText)
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }

            print(placemark.postalAddressFormatted ?? "")
            let lines = placemark.postalAddressFormatted!.split(whereSeparator: \.isNewline)
            //print(lines[1])
            self.position=String(lines[1])
            if (self.position.containsWhitespace == true){
                let fullNameArr = self.position.components(separatedBy: " ")

                self.name1    = fullNameArr[0]
                self.name2 = fullNameArr[1]
            }
        }
        
        
        
    }
    

    
    
    
    
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "danger", for:indexPath)
        
        
        let place = places[indexPath.row]
        cell.textLabel?.numberOfLines = 3
        cell.textLabel!.text = "District: \(place.District)\n" + "Buildings: \(place.building)\n" + "Date: \(place.date)"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    
    
    @IBAction func search(_ sender: Any) {
        //position = field.text!
       // position=position.capitalized
        runAnimation = false
        print("You are now in \(position)")
        labeltext.text="You are now in \(position)"
        if position.isEmpty{
            url=URL(string:"https://api.data.gov.hk/v2/filter?q=%7B%22resource%22%3A%22http%3A%2F%2Fwww.chp.gov.hk%2Ffiles%2Fmisc%2Fbuilding_list_eng.csv%22%2C%22section%22%3A1%2C%22format%22%3A%22json%22%7D")
        }
        else if (name2.isEmpty){
        url = URL(string: "https://api.data.gov.hk/v2/filter?q=%7B%22resource%22%3A%22http%3A%2F%2Fwww.chp.gov.hk%2Ffiles%2Fmisc%2Fbuilding_list_eng.csv%22%2C%22section%22%3A1%2C%22format%22%3A%22json%22%2C%22filters%22%3A%5B%5B1%2C%22ct%22%2C%5B%22\(position)%22%5D%5D%5D%7D")
            


        
        
        }else{
            url = URL(string: "https://api.data.gov.hk/v2/filter?q=%7B%22resource%22%3A%22http%3A%2F%2Fwww.chp.gov.hk%2Ffiles%2Fmisc%2Fbuilding_list_eng.csv%22%2C%22section%22%3A1%2C%22format%22%3A%22json%22%2C%22filters%22%3A%5B%5B1%2C%22ct%22%2C%5B%22\(name1)%20\(name2)%22%5D%5D%5D%7D")
        }
        
        self.activityIndicator.startAnimating()
        URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
            guard let data = data else { return }
            if let jsonString = String(data: data, encoding: .utf8) {
                               //print(jsonString)
                if (jsonString == "[]"){
                   // print("it is not district")
                    //self.buildingName()
                }
            else {
            
            do {
                
                self.places = try JSONDecoder().decode([Places].self, from: data)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()

                }
                
            } catch {
                print("Error is : \n\(error)")
            }
            }
            }
        }.resume()
        

        
    }
    
    /*
    func buildingName(){
       
        url = URL(string: "https://api.data.gov.hk/v2/filter?q=%7B%22resource%22%3A%22http%3A%2F%2Fwww.chp.gov.hk%2Ffiles%2Fmisc%2Fbuilding_list_eng.csv%22%2C%22section%22%3A1%2C%22format%22%3A%22json%22%2C%22filters%22%3A%5B%5B2%2C%22ct%22%2C%5B%22\(position)%22%5D%5D%5D%7D")
        
        URLSession.shared.dataTask(with: url!) { [unowned self] (data, response, error) in
            guard let data = data else { return }
            if let jsonString = String(data: data, encoding: .utf8) {
                if (jsonString == "[]"){
                    print("it is not building")
                  
                }
            }
            
            do {
                self.places = try JSONDecoder().decode([Places].self, from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()

                }
                
            } catch {
                print("Error is : \n\(error)")
            }
            
        }.resume()
    }
    
    */
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
        
    }
    
    
    
    
    
    
}
extension CLPlacemark {
    /// street name, eg. Infinite Loop
    var streetName: String? { thoroughfare }
    /// // eg. 1
    var streetNumber: String? { subThoroughfare }
    /// city, eg. Cupertino
    var city: String? { locality }
    /// neighborhood, common name, eg. Mission District
    var neighborhood: String? { subLocality }
    /// state, eg. CA
    var state: String? { administrativeArea }
    /// county, eg. Santa Clara
    var county: String? { subAdministrativeArea }
    /// zip code, eg. 95014
    var zipCode: String? { postalCode }
    /// postal address formatted
    @available(iOS 11.0, *)
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}

extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}



extension String {
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}
