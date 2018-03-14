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
class SettingsViewController: UIViewController {

    @IBOutlet weak var pushDescriptionLabel: UILabel!
    @IBOutlet weak var paperSwitch1: paperSwitch!
    @IBOutlet var sourceButton: UIButton!
    @IBOutlet var paperSwitch2: paperSwitch!
    @IBOutlet var watsonDescriptionLabel: UILabel!
    
    let chooseArticleDropDown = DropDown()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseArticleDropDown
        ]
    }()
    let keyValues = [
        "International news",
        "finance",
        "sports",
        "investments",
        "politics",
        "Entertainment",
        "Health",
        "Education",
        "Arts and culture",
        "Science and technology"
    ]

    
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
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        if (UserDefaults.standard.bool(forKey: "isPushEnabled")){
            self.paperSwitch1.setOn(true, animated: false)
        }
        if (UserDefaults.standard.bool(forKey: "isWatsonEnabled")){
            self.paperSwitch2.setOn(true, animated: false)
        }
        sourceButton.setTitle(chooseArticleDropDown.dataSource[appDelegate.sourceID], for: .normal)
    }
    
    func setupChooseArticleDropDown() {
        chooseArticleDropDown.anchorView = sourceButton
        chooseArticleDropDown.bottomOffset = CGPoint(x: 0, y: sourceButton.bounds.height)

        chooseArticleDropDown.dataSource = [
            "International news",
            "finance",
            "sports",
            "investments",
            "politics",
            "Entertainment",
            "Health",
            "Education",
            "Arts and culture",
            "Science and technology"
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
    
    @IBAction func chooseArticle(_ sender: AnyObject) {
        chooseArticleDropDown.show()
    }
    
    @IBAction func BackButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
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
}
