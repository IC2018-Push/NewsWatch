//
//  ViewController.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 02/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import OpenWhisk
import UserNotifications
import DropDown
import CoreLocation

class MainTableViewController: UITableViewController {
    
    let kCloseCellHeight: CGFloat = 179
    let kOpenCellHeight: CGFloat = 488
    
    @IBOutlet var noDataLabel: UILabel!
    @IBOutlet var locationSelector: UIBarButtonItem!
    let kRowsCount = 10
    var tableValue:NSArray = [];
    var cellHeights = [CGFloat]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator = UIActivityIndicatorView()

    var locationManager = CLLocationManager()

    let chooseArticleDropDown = DropDown()
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseArticleDropDown
        ]
    }()
    let keyValues = [
        "Current",
        "Bangalore",
        "Newyork",
        "London",
        "Lasvegas"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator()
       self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        createCellHeightsArray()
        self.noDataLabel.isHidden = true;
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        setupChooseArticleDropDown();
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        if CLLocationManager.locationServicesEnabled()
        {
            switch(CLLocationManager.authorizationStatus())
            {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorize.")
                let latitude: CLLocationDegrees = (locationManager.location?.coordinate.latitude)!
                let longitude: CLLocationDegrees = (locationManager.location?.coordinate.longitude)!
                let location = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                    self.locationManager.stopUpdatingLocation()
                    if error != nil {
                        return
                    }else if let country = placemarks?.first?.country,
                        let city = placemarks?.first?.administrativeArea {
                        self.appDelegate.location = city
                        self.loadData()
                    }
                    else {
                        self.loadData()
                    }
                })
                break
                
            case .notDetermined:
                print("Not determined.")
                 self.loadData()
                break
                
            case .restricted:
                print("Restricted.")
                self.loadData()
                break
                
            case .denied:
                 self.loadData()
                print("Denied.")
            }
        }
        
        //self.tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    func setupChooseArticleDropDown() {
        chooseArticleDropDown.anchorView = locationSelector
        chooseArticleDropDown.bottomOffset = CGPoint(x: 0, y: 0)
        
        chooseArticleDropDown.dataSource = [
            "Current",
            "Bangalore",
            "Newyork",
            "London",
            "Lasvegas"
        ]
        
        chooseArticleDropDown.selectionAction = { [unowned self] (index, item) in
            if (self.keyValues[index] as String) != "Current" {
                 self.appDelegate.location = self.keyValues[index] as String
            }
            self.tableValue = []
            self.tableView.reloadData()
            self.indicator.startAnimating()
            self.noDataLabel.isHidden = true;
            self.loadData()
        }
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 10, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.color = UIColor.green
        self.view.addSubview(indicator)
        indicator.startAnimating()
        self.noDataLabel.isHidden = true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if appDelegate.valueChanged {
            self.tableValue = []
            self.tableView.reloadData()
            indicator.startAnimating()
            self.noDataLabel.isHidden = true;
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appDelegate.valueChanged {
            loadData()
            appDelegate.valueChanged = false
            self.noDataLabel.isHidden = true;
        }
     }
    
    func loadData(){
        self.noDataLabel.isHidden = true;
        let credentialsConfiguration = WhiskCredentials(accessKey:appDelegate.whiskAccessKey, accessToken: appDelegate.whiskAccessToken)
        
        let whisk = Whisk(credentials: credentialsConfiguration)
        whisk.verboseReplies = true

        var params = Dictionary<String, String>()
        params["searchKey"] = appDelegate.source
        params["apiKey"] = appDelegate.newsAPIKey
        params["language"] = appDelegate.language
        params["location"] = appDelegate.location
        do {
            try whisk.invokeAction(name: appDelegate.whiskActionName, package: "", namespace: appDelegate.whiskNameSpace, parameters: params as AnyObject?, hasResult: true, callback: {(reply, error) -> Void in
                
                if let error = error {
                    //do something
                    print("Error invoking action \(error.localizedDescription)")
                    
                } else {
                    var result = reply?["response"]?["result"] as? [String: AnyObject]
                    if (((result?["result"] as! NSArray).count > 0)) {
                        print("Got result \(result?["result"] as! NSArray)")
                        self.tableValue = (result?["result"] as? NSArray)!
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.noDataLabel.isHidden = true;
                    } else {
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.noDataLabel.isHidden = false;
                    }
                    
                }
                
            })
        } catch {
            print("Error \(error)")
        }
        
    }
    // MARK: configure
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(kCloseCellHeight)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableValue.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard case let cell as ActionCell = cell else {
            return
        }
        
        cell.backgroundColor = UIColor.clear
        
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight {
            cell.selectedAnimation(false, animated: false, completion:nil)
        } else {
            cell.selectedAnimation(true, animated: false, completion: nil)
        }
        
        cell.setValues = tableValue[indexPath.row] as! [String : AnyObject]
        cell.number = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoldingCell", for: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[(indexPath as NSIndexPath).row]
    }
    
    // MARK: Table vie delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        if cell.isAnimating() {
            return
        }
        var duration = 0.0
        if cellHeights[(indexPath as NSIndexPath).row] == kCloseCellHeight { // open cell
            cellHeights[(indexPath as NSIndexPath).row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[(indexPath as NSIndexPath).row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.8
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
    }
    
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        self.tableValue = []
        self.tableView.reloadData()
        indicator.startAnimating()
        loadData()
        
    }
 
    @IBAction func selectCity(_ sender: UIBarButtonItem) {
        
        chooseArticleDropDown.show()
    }
}

