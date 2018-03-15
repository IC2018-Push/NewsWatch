//
//  ArticleViewController.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 15/03/18.
//  Copyright © 2018 Ananth. All rights reserved.
//

import UIKit

import IBMAppLaunch

class ArticleViewController: UIViewController {
    
    var articleTitle:String?
    var articleDescription:String?
    var articleImage:UIImage?
    var authorName:String?
    @IBOutlet weak var shareButton: UIImageView!
    @IBOutlet weak var rssDescription: UITextView!
    @IBOutlet weak var rssImage: UIImageView!
    @IBOutlet weak var rssTitle: UILabel!
    @IBOutlet weak var rssAuthor: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        rssTitle.numberOfLines = 3
        rssTitle.text = articleTitle
        rssDescription.text = articleDescription
        if (authorName?.isEmpty)!{
            authorName = "By Anonymous"
        } else {
            authorName = "By " + authorName!
        }
        rssAuthor.text = authorName
        rssImage.image = articleImage
        do {
            if try AppLaunch.sharedInstance.isFeatureEnabled(featureCode: "_6hlx9y825") {
                shareButton.isHidden = false
            } else {
                print("AppLaunch SDK is not Initialized")
            }
        }
        catch{
            print("Not initalized")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
