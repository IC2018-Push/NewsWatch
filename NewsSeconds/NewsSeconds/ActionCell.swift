//
//  DemoCell.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 02/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit

class ActionCell: FoldingCell {
    
    @IBOutlet var newsDescription: UILabel!
    @IBOutlet var dateTime: UILabel!
    @IBOutlet var dateDay: UILabel!
    @IBOutlet var authorName1: UILabel!
    @IBOutlet var smallTitle: UILabel!
    @IBOutlet weak var openNumberLabel: UILabel!
    var OpenURL: String = ""
    @IBOutlet var newsImage: UIImageView!

    
    var number: Int = 0 {
        didSet {
            //openNumberLabel.text = String(number)
        }
    }
    
    var setValues: [String:AnyObject] = [:] {
        didSet {
            
            
            
            if let value = setValues["title"] as? String{
                openNumberLabel.text = value
                smallTitle.text = value
            }else{
                openNumberLabel.text = "<Not Availbale>"
                smallTitle.text = "<Not Availbale>"
            }
            
            
            if let value = setValues["description"] as? String{
                 newsDescription.text = value
            }else{
                newsDescription.text = "<Not Availbale>"
            }
            
            
            if let value = setValues["author"] as? String{
                authorName1.text = value
            }else{
                authorName1.text = "Our Editor"
            }
            
            if var dateString = setValues["publishedAt"] as? String{
                dateString = String(dateString[dateString.startIndex..<dateString.index(dateString.startIndex, offsetBy: 19)]) 

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.locale = Locale.init(identifier: "en_GB")
                let dateObj = dateFormatter.date(from: dateString)
                
                dateFormatter.dateFormat = "hh:mm a"
                dateTime.text = (dateFormatter.string(from: dateObj!))
                
                
                let calendar = NSCalendar.autoupdatingCurrent
                let someDate:Date = dateObj!
                if calendar.isDateInYesterday(someDate as Date) {
                    dateDay.text = "Yesterday"
                }
                else if calendar.isDateInToday(someDate as Date) {
                    dateDay.text = "Today"
                }
                else{
                    dateFormatter.dateFormat = "MMM dd yyyy"
                    dateDay.text = (dateFormatter.string(from: dateObj!))
                }
            }else{
                dateDay.text = "Older Post"
                dateTime.text = ""
            }
            
            if let value = setValues["urlToImage"] as? String, value != "" {
                newsImage.imageFromServerURL(urlString: value)
            }else{
                newsImage.imageFromServerURL(urlString: "http://wallpaper-gallery.net/images/news-images/news-images-24.jpg")
            }
            
            if let value = setValues["url"] as? String{
                OpenURL = value
            }else{
                OpenURL = "https://www.nytimes.com/"
            }

        }
    }
    
   
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
}

// MARK: Actions
extension ActionCell {
    
    @IBAction func buttonHandler(_ sender: AnyObject) {
        print("tap")
        if OpenURL != "" {
            UIApplication.shared.open(URL(string: OpenURL)!, options: [:], completionHandler: nil)
            
        }
        
    }
}

//extension UIImageView {
//    public func imageFromServerURL(urlString: String) {
//        
//        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
//            
//            if error != nil {
//                print(error ?? "Error!!!")
//                return
//            }
//            DispatchQueue.main.async(execute: { () -> Void in
//                let image = UIImage(data: data!)
//                self.image = image
//            })
//            
//        }).resume()
//    }}

