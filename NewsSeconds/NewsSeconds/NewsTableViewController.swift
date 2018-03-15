//
//  NewsTableViewController.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 15/03/18.
//  Copyright © 2018 Ananth. All rights reserved.
//

import UIKit
import OpenWhisk
import UserNotifications
import DropDown
import CoreLocation
import IBMAppLaunch

class NewsTableViewController: UITableViewController {
    
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var reloadButton: UIBarButtonItem!
    @IBOutlet var noDataLabel: UILabel!
    @IBOutlet var locationSelector: UIBarButtonItem!
    var tableValue:NSArray = [];
    weak var gameTimer: Timer?

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indicator = UIActivityIndicatorView()
    var indicatorColor = UIColor.green
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
        pollOffers()
        self.noDataLabel.isHidden = true;
        locationManager.delegate = self as? CLLocationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        self.tableView.separatorColor = UIColor.clear
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        indicator.color = self.indicatorColor
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
        self.pollOffers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if appDelegate.valueChanged {
            loadData()
            appDelegate.valueChanged = false
            self.noDataLabel.isHidden = true;
        }
        self.pollOffers()
    }
    
    
    func loadData(){
        self.noDataLabel.isHidden = true;
        self.tableView.separatorColor = UIColor.clear
        let credentialsConfiguration = WhiskCredentials(accessKey:appDelegate.whiskAccessKey, accessToken: appDelegate.whiskAccessToken)
        
        let whisk = Whisk(credentials: credentialsConfiguration)
        whisk.verboseReplies = true
        
        var params = Dictionary<String, String>()
        params["searchKey"] = appDelegate.source
        params["language"] = "English"
        params["convertLanguage"] = appDelegate.language
        params["location"] = appDelegate.location
        do {
            try whisk.invokeAction(name: appDelegate.whiskActionName, package: "", namespace: appDelegate.whiskNameSpace, parameters: params as AnyObject?, hasResult: true, callback: {(reply, error) -> Void in
                
                if let error = error {
                    //do something
                    print("Error invoking action \(error.localizedDescription)")
                    self.indicator.stopAnimating()
                    self.indicator.hidesWhenStopped = true
                    self.noDataLabel.isHidden = false;
                } else {
                    var result = reply?["response"]?["result"] as? [String: AnyObject]
                    if (((result?["result"] as! NSArray).count > 0)) {
                        print("Got result \(result?["result"] as! NSArray)")
                        self.tableValue = (result?["result"] as? NSArray)!
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        self.noDataLabel.isHidden = true;
                        self.tableView.setContentOffset(.zero, animated: true)
                        self.tableView.separatorColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                        self.pollOffers();
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
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableValue.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RSSItem", for: indexPath) as! NewsTableViewCell
        
        let data = tableValue[indexPath.row] as! [String : AnyObject]
        
        if let value = data["title"] as? String {
            cell.rssTitle.text = value
        } else {
            cell.rssTitle.text = "<Not Availbale>"
        }
        if let value = data["description"] as? String{
            cell.rssDescription.text = value
        }else{
            cell.rssDescription.text = "<Not Availbale>"
        }
        
        cell.rssDescription.textContainer.maximumNumberOfLines = 2
        cell.rssDescription.textContainer.lineBreakMode = .byTruncatingTail
        if let value = data["urlToImage"] as? String, value != "" {
            cell.rssImage.imageFromServerURL(urlString: value)
        }else{
            cell.rssImage.imageFromServerURL(urlString: "http://wallpaper-gallery.net/images/news-images/news-images-24.jpg")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableValue[indexPath.row] as! [String : AnyObject]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArticleView") as! ArticleViewController
//        vc.articleTitle = data["title"]?.stringValue
//        vc.articleDescription = data["description"]?.stringValue
//        vc.authorName = data["author"]?.stringValue
        
        if let value = data["title"] as? String {
            vc.articleTitle = value
        } else {
            vc.articleTitle = "<Not Availbale>"
        }
        if let value = data["description"] as? String{
            vc.articleDescription = value
        }else{
            vc.articleDescription = "<Not Availbale>"
        }
        if let value = data["author"] as? String{
            vc.authorName = value
        }else{
            vc.authorName = "Our Editor"
        }
        var imageData:NSData
        do {
            if let imagurl = data["urlToImage"] as? String, !imagurl.isEmpty {
                imageData = try NSData(contentsOf: URL(string: imagurl)!)
            } else{
                imageData = try! NSData(contentsOf: URL(string: "http://wallpaper-gallery.net/images/news-images/news-images-24.jpg")!)
            }
        } catch  {
            imageData = NSData()
        }
        vc.articleImage = UIImage(data: imageData as Data)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        self.tableValue = []
        self.tableView.reloadData()
        indicator.startAnimating()
        loadData()
        
    }
    
    
    func pollOffers() {
        
        do {
            if try AppLaunch.sharedInstance.isFeatureEnabled(featureCode: "_lyyy2dnj4") {
               
                let buttonColor = try AppLaunch.sharedInstance.getPropertyofFeature(featureCode: "_lyyy2dnj4", propertyCode: "_7d164vjy1")
                
                self.tableView.separatorColor = hexStringToUIColor(buttonColor)
                self.settingsButton.tintColor = hexStringToUIColor(buttonColor)
                self.reloadButton.tintColor = hexStringToUIColor(buttonColor)
                self.locationSelector.tintColor = hexStringToUIColor(buttonColor)
                self.indicatorColor = hexStringToUIColor(buttonColor)
                
            } else {
                self.settingsButton.tintColor = hexStringToUIColor("#026FBA")
                self.reloadButton.tintColor = hexStringToUIColor("#026FBA")
                self.locationSelector.tintColor = hexStringToUIColor("#026FBA")
                self.indicatorColor = UIColor.green
                if self.tableValue.count > 0 {
                    self.tableView.separatorColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                } else {
                    self.tableView.separatorColor = UIColor.clear
                }
            }
            
        } catch {
            print("AppLaunch SDK is not Initialized")
        }
    }
    
    @IBAction func selectCity(_ sender: UIBarButtonItem) {
        
        chooseArticleDropDown.show()
    }
    
    private func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "Error!!!")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}
