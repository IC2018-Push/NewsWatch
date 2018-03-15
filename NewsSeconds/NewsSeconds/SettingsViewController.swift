//
//  SettingsViewController.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 03/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import DropDown
import UserNotifications
import IBMAppLaunch

class SettingsViewController: UIViewController {

    @IBOutlet weak var pushDescriptionLabel: UILabel!
    @IBOutlet weak var paperSwitch1: paperSwitch!
    @IBOutlet var sourceButton: UIButton!
    @IBOutlet var paperSwitch2: paperSwitch!
    @IBOutlet var watsonDescriptionLabel: UILabel!
    @IBOutlet var languageButton: UIButton!
    @IBOutlet var customLabel: UILabel!
    @IBOutlet var countryLabel: UILabel!
    
    @IBOutlet var typeLabel: UILabel!
    let chooseArticleDropDown = DropDown()
    let chooseArticleDropDown1 = DropDown()

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseArticleDropDown
        ]
    }()
    
    lazy var dropDowns1: [DropDown] = {
        return [
            self.chooseArticleDropDown1
        ]
    }()
    
    let keyValues = [
        "finance",
        "sports",
        "investments",
        "politics",
        "Entertainment",
        "Health",
        "Education",
        "Arts",
        "culture",
        "Science",
        "technology"
    ]
    
    let keyValues1 = [
        "en",
        "es",
        "ko",
        "nl",
        "fr",
        "it",
        "de",
        "js",
        "zh",
        "tr",
        "pl",
        "pt",
        "ru",
        "ar"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.appDelegate.valueChanged = false
        
        self.paperSwitch1.animationDidStartClosure = {(onAnimation: Bool) in
            
            self.animateLabel(self.pushDescriptionLabel, onAnimation: onAnimation, duration: self.paperSwitch1.duration)
        }
        
        self.paperSwitch2.animationDidStartClosure = {(onAnimation: Bool) in
            
            self.animateLabel(self.watsonDescriptionLabel, onAnimation: onAnimation, duration: self.paperSwitch2.duration)
        }

        setupChooseArticleDropDown();
        setupChooseArticleDropDown1();
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        dropDowns1.forEach { $0.dismissMode = .onTap }
        dropDowns1.forEach { $0.direction = .any }
        sourceButton.isHidden = true
        languageButton.isHidden = true
        customLabel.isHidden = false
        
        if (UserDefaults.standard.bool(forKey: "isPushEnabled")){
            self.paperSwitch1.setOn(true, animated: false)
        }
        if (UserDefaults.standard.bool(forKey: "isWatsonEnabled")){
            self.paperSwitch2.setOn(true, animated: false)
        }
        sourceButton.setTitle(chooseArticleDropDown.dataSource[appDelegate.sourceID], for: .normal)
        pollOffers()
    }
    
    
    func pollOffers() {
        
        do {
            if try AppLaunch.sharedInstance.isFeatureEnabled(featureCode: "_lyyy2dnj4") {
                
                 let backgroundColor = try AppLaunch.sharedInstance.getPropertyofFeature(featureCode: "_lyyy2dnj4", propertyCode: "_g3ka8rs3m")
                self.view.backgroundColor = hexStringToUIColor(backgroundColor)
                sourceButton.isHidden = false
                languageButton.isHidden = false
                customLabel.isHidden = true
                countryLabel.isHidden = false
                typeLabel.isHidden = false
            } else {
                sourceButton.isHidden = true
                languageButton.isHidden = true
                countryLabel.isHidden = true
                typeLabel.isHidden = true
                customLabel.isHidden = false
                self.view.backgroundColor = UIColor.white
            }
            
        } catch {
            sourceButton.isHidden = true
            languageButton.isHidden = true
            countryLabel.isHidden = true
            typeLabel.isHidden = true
            customLabel.isHidden = false
            self.view.backgroundColor = UIColor.white
            print("AppLaunch SDK is not Initialized")
        }
    }
    func setupChooseArticleDropDown() {
        chooseArticleDropDown.anchorView = sourceButton
        self.sourceButton.setTitle(self.appDelegate.source,for: .normal)
        chooseArticleDropDown.bottomOffset = CGPoint(x: 0, y: sourceButton.bounds.height)

        chooseArticleDropDown.dataSource = [
            "finance",
            "sports",
            "investments",
            "politics",
            "Entertainment",
            "Health",
            "Education",
            "Arts",
            "culture",
            "Science",
            "technology"
        ]
        
        chooseArticleDropDown.selectionAction = { [unowned self] (index, item) in
            self.sourceButton.setTitle(item, for: .normal)
            self.appDelegate.oldSource = self.appDelegate.source
            self.appDelegate.source = self.keyValues[index] as String
            self.appDelegate.sourceID = index
            self.appDelegate.sourceDescription = self.chooseArticleDropDown.dataSource[self.appDelegate.sourceID]

            UserDefaults.standard.set(self.appDelegate.oldSource, forKey: "oldSourceValue")
            UserDefaults.standard.set(self.appDelegate.source, forKey: "sourceValue")
            UserDefaults.standard.set(self.appDelegate.sourceID, forKey: "sourceValueID")
            UserDefaults.standard.set(self.appDelegate.sourceDescription, forKey: "sourceDescription")
            UserDefaults.standard.synchronize()

            self.appDelegate.valueChanged = true
            self.appDelegate.registerForTag()
        }
    }
    
    func setupChooseArticleDropDown1() {
        chooseArticleDropDown1.anchorView = languageButton
        self.languageButton.setTitle(self.appDelegate.language,for: .normal)
        chooseArticleDropDown1.bottomOffset = CGPoint(x: 0, y: languageButton.bounds.height)
        
        chooseArticleDropDown1.dataSource = [
            "English",
            "Spanish",
            "Korean",
            "Dutch",
            "French",
            "Italian",
            "German",
            "Japanese",
            "Chinese",
            "Turkish",
            "Polish",
            "Portuguese",
            "Russian",
            "Arabic"
        ]
        
        chooseArticleDropDown1.selectionAction = { [unowned self] (index, item) in
            self.languageButton.setTitle(item, for: .normal)
             self.appDelegate.oldLanguage = self.appDelegate.language
            self.appDelegate.language =  String(describing: LanguageEnum(rawValue: self.keyValues1[index] as String)!)
            
            UserDefaults.standard.set(self.appDelegate.oldLanguage, forKey: "oldLanguage")
            UserDefaults.standard.set(self.appDelegate.language, forKey: "language")
            UserDefaults.standard.synchronize()
            
            self.appDelegate.valueChanged = true
            self.appDelegate.registerForTag()
        }
    }
    
    @IBAction func chooseArticle(_ sender: AnyObject) {
        chooseArticleDropDown.show()
    }
    
    @IBAction func BackButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        chooseArticleDropDown1.show()
    }
    fileprivate func animateLabel(_ label: UILabel, onAnimation: Bool, duration: TimeInterval) {
        UIView.transition(with: label, duration: duration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            label.textColor = onAnimation ? UIColor.white : UIColor.black
        }, completion:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enablePush(_ sender: UISwitch) {
        
        if(sender.isOn){
            UserDefaults.standard.set(true, forKey: "isPushEnabled")
            self.appDelegate.registerForPush()
        }else{
            UserDefaults.standard.set(false, forKey: "isPushEnabled")
            self.appDelegate.unRegisterPush()
        }
        UserDefaults.standard.synchronize()
    }
   
    @IBAction func enableWatson(_ sender: UISwitch) {
        
        if(sender.isOn){
            UserDefaults.standard.set(true, forKey: "isWatsonEnabled")
        }else{
            UserDefaults.standard.set(false, forKey: "isWatsonEnabled")
        }
        UserDefaults.standard.synchronize()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pollOffers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        self.pollOffers()
    }
}
