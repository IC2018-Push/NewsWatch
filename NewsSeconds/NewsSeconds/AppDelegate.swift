//
//  AppDelegate.swift
//  NewsSeconds
//
//  Created by Anantha Krishnan K G on 02/03/17.
//  Copyright © 2017 Ananth. All rights reserved.
//

import UIKit
import BMSPush
import BMSCore
import SwiftMessages
import AVFoundation
import TextToSpeechV1
import UserNotifications
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,AVAudioPlayerDelegate {
    
    
    //OpenWhisk Credentials
    var whiskAccessKey:String = "OpenWhisk Key"
    var whiskAccessToken:String = "OpenWhisk token"
    var whiskActionName:String = "Swift action name"
    var whiskNameSpace:String = "space name"

     //Push Service Credentials
    var pushAppGUID:String = "Your push appGUID"
    var pushAppClientSecret:String = "Your push appSecret"
    var pushAppRegion:String = "Your push appregion"
    
    //Watson Text-to-speech credentials
    var watsonTextToSpeachUsername:String = "Watson Text to Speech username"
    var watsonTextToSpeachPassword:String = "Watson Text to Speech password"
    
   // http://webhose.io/filterWebContent?token=7a563830-7222-466c-8b84-ca23b29aab8f&format=json&sort=crawled&q=%22donald%20trump%22%20language%3Aenglish
    //News webhose.io API key - From https://webhose.io/
    var newsAPIKey:String = "7a563830-7222-466c-8b84-ca23b29aab8f"

    
    weak var gameTimer: Timer?
    var soundPlayer: AVAudioPlayer?
    var audioPlayer = AVAudioPlayer() // see note below
    var window: UIWindow?
    
    var urlToOpen:String = UserDefaults.standard.value(forKey: "urlToOpen") != nil ?  UserDefaults.standard.value(forKey: "urlToOpen") as! String : ""

    var sourceDescription:String = UserDefaults.standard.value(forKey: "sourceDescription") != nil ?  UserDefaults.standard.value(forKey: "sourceDescription") as! String : "International news"

    var source:String = UserDefaults.standard.value(forKey: "sourceValue") != nil ?  UserDefaults.standard.value(forKey: "sourceValue") as! String : "International news"
    var sourceID:Int = UserDefaults.standard.value(forKey: "sourceValueID") != nil ?  UserDefaults.standard.integer(forKey:"sourceValueID")  : 0
    var oldSource:String = UserDefaults.standard.value(forKey: "oldSourceValue") != nil ?  UserDefaults.standard.value(forKey: "oldSourceValue") as! String :"International news"
    
    var language:String = "english"
    var location:String = "New York"
    
    var valueChanged:Bool = false
    var doIt = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         doIt = false
        
        
        
        if let path = Bundle.main.path(forResource: "bluemixCredentials", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            // use swift dictionary as normal
            
            whiskAccessKey = dict["whiskAccessKey"] as! String;
            whiskAccessToken = dict["whiskAccessToken"] as! String;
            whiskActionName = dict["whiskActionName"] as! String;
            whiskNameSpace = dict["whiskNameSpace"] as! String;
            pushAppGUID = dict["pushAppGUID"] as! String;
            pushAppClientSecret = dict["pushAppClientSecret"] as! String;
            pushAppRegion = dict["pushAppRegion"] as! String;
            watsonTextToSpeachUsername = dict["watsonTextToSpeachUsername"] as! String;
            watsonTextToSpeachPassword = dict["watsonTextToSpeachPassword"] as! String;
            newsAPIKey = dict["newsAPIKey"] as! String;
        }

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UserDefaults.standard.set("", forKey: "newsURL")
        UserDefaults.standard.synchronize()
        urlToOpen = ""
        UIApplication.shared.applicationIconBadgeNumber = 0;
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()


        if (UserDefaults.standard.bool(forKey: "isPushEnabled")){
            registerForPush()
        }
        
        gameTimer?.invalidate()
        let ff = Date()
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.year,.month,.weekOfYear,.day,.hour,.minute,.second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .full
        dateComponentsFormatter.string(from: Date(), to: ff)
        
        return true
    }
    
    func registerForPush () {
        
        let myBMSClient = BMSClient.sharedInstance
        myBMSClient.initialize(bluemixRegion: pushAppRegion)
        let push =  BMSPushClient.sharedInstance
        push.initializeWithAppGUID(appGUID: pushAppGUID, clientSecret:pushAppClientSecret)
        
    }
    func unRegisterPush () {
        
        // MARK:  RETRIEVING AVAILABLE SUBSCRIPTIONS
        
        let push =  BMSPushClient.sharedInstance
        
        push.unregisterDevice(completionHandler: { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                print( "Response during unregistering device : \(String(describing: response))")
                print( "status code during unregistering device : \(String(describing: statusCode))")
                UIApplication.shared.unregisterForRemoteNotifications()
            }
            else{
                print( "Error during unregistering device \(error) ")
            }
        })
        
    }
    
    func registerForTag(){
        
        if (UserDefaults.standard.bool(forKey:"isPushEnabled")){
            
            let push =  BMSPushClient.sharedInstance
            
            push.unsubscribeFromTags(tagsArray: [self.oldSource]) { (response, status, error) in
                
                if error.isEmpty {
                    
                    print( "Response during device Unsubscribing : \(String(describing: response))")
                    
                    print( "status code during device Unsubscribing : \(String(describing: status))")
                    
                    push.subscribeToTags(tagsArray: [self.source]) { (response, status, error) in
                        
                        if error.isEmpty {
                            print( "Response during device subscription : \(String(describing: response))")
                            print( "status code during device subscription : \(String(describing: status))")
                           
                        }
                        else{
                            print( "Error during device subscription \(error) ")
                            
                        }
                    }
                }
                else{
                    print( "Error during Unsubscribing \(error) ")
                    
                }
            }
        }else{
            self.showAlert(title: "Error !!!", message: "Enable Push Service",theme: .error)
        }
    }
    
    func application (_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        
        let push =  BMSPushClient.sharedInstance
        
        push.registerWithDeviceToken(deviceToken: deviceToken) { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                
                print( "Response during device registration : \(String(describing: response))")
                
                print( "status code during device registration : \(String(describing: statusCode))")
                self.showAlert(title: "Awesome !!", message: "Successfully registratered for push notifications", theme: .success)

                
                push.subscribeToTags(tagsArray: [self.source]) { (response, status, error) in
                    
                    if error.isEmpty {
                        
                        print( "Response during device subscription : \(response)")
                        
                        print( "status code during device subscription : \(status)")
                    }
                    else{
                        print( "Error during device subscription \(error) ")
                    }
                }
            }
            else{
                print( "Error during device registration \(error) ")
            }
        }
    }
    
    //Called if unable to register for APNS.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        let message:String = "Error registering for push notifications: \(error.localizedDescription)" as String
        
        self.showAlert(title: "Registering for notifications", message: message, theme: .warning)
        
    }
    
    func showTimer(date:Date) -> Bool {
        
        while(Date().minutes(from:date) < 1){
            print(Date().minutes(from:date))
        }
        return true
    }
   
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let payLoad = ((((userInfo as NSDictionary).value(forKey: "aps") as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "body") as! String)
        
        self.showAlert(title: "Recieved Push notifications", message: payLoad, theme: .info)
        
        
        if(UIApplication.shared.applicationState == .active){
            
            print("Will not play the sound")
           
        }else if(UserDefaults.standard.bool(forKey: "isWatsonEnabled")) {
            doIt = true
            
            
          if(doIt){
            //Timer.scheduledTimer(withTimeInterval: 10, repeats: false){_ in
            let payLoadAlert = (((userInfo as NSDictionary).value(forKey: "aps") as! NSDictionary).value(forKey: "alert") as! NSDictionary)
            
            let respJson = (userInfo as NSDictionary).value(forKey: "payload") as! String
            let data = respJson.data(using: String.Encoding.utf8)
            
            let jsonResponse:NSDictionary = try! JSONSerialization.jsonObject(with: data! , options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        
            let messageValue:String = jsonResponse.value(forKey: "data") as! String
            let newsURL:String = jsonResponse.value(forKey: "newsURL") as! String
            
            UserDefaults.standard.set(newsURL, forKey: "newsURL")
            UserDefaults.standard.synchronize()
            self.urlToOpen = newsURL
        
        let title = "Latest News From \(self.sourceDescription)"
        let subtitle = payLoadAlert.value(forKey: "body") as! String;
        let alert = messageValue
            
            let watsonMessage = "\(title), \(subtitle), \(alert)"
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .duckOthers)
                    try AVAudioSession.sharedInstance().setActive(true)
                    UIApplication.shared.beginReceivingRemoteControlEvents()
                    let textToSpeech = TextToSpeech(username:watsonTextToSpeachUsername, password: watsonTextToSpeachPassword)
                    
                    textToSpeech.synthesize(watsonMessage as String, success: { data in
                        
                        self.audioPlayer = try! AVAudioPlayer(data: data)
                        self.audioPlayer.prepareToPlay()
                        //self.audioPlayer.play()
                        
                        if #available(iOS 10.0, *) {
                            let content = UNMutableNotificationContent()
                            
                            content.title = title
                            content.subtitle = subtitle
                            content.body = alert
                            
                            // Deliver the notification in five seconds.
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            let request = UNNotificationRequest(identifier: "watsonPush", content: content, trigger: trigger)
                            
                            // Schedule the notification.
                            let center = UNUserNotificationCenter.current()
                            center.delegate = self
                            center.removeAllPendingNotificationRequests()
                            center.removeAllDeliveredNotifications()
                            // self.audioPlayer.play()
                            completionHandler(UIBackgroundFetchResult.newData)
                            center.add(request) { (error) in
                                print("Success")
                                self.audioPlayer.play()
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        print("should have been added")
                    })
                }
                catch {}
          }
        }
    }
    
    func showAlert (title:String , message:String, theme:Theme){
        
        // create the alert
       
        
        
        let view = MessageView.viewFromNib(layout: .cardView)
        
        // Theme message elements with the warning style.
        view.configureTheme(theme)
        var iconText = "😊"
        
        switch theme {
        case .error:
            iconText = "😱"
            break;
            
        case .success:
            iconText = "👏"
            break;
            
        case .warning:
            iconText = "🙄"
            break;
            
        case .info:
            iconText = "😊"
            break;
        }
        // Add a drop shadow.
        view.configureDropShadow()
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        view.configureContent(title: title, body: message, iconText: iconText)
        view.button?.isHidden = true
        // Show the message.
        SwiftMessages.show(view: view)

    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        doIt = false
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if(urlToOpen.isEmpty) == false{
            UIApplication.shared.open(URL(string: urlToOpen)!, options: [:], completionHandler: nil)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UserDefaults.standard.set("", forKey: "newsURL")
            UserDefaults.standard.synchronize()
            urlToOpen = ""
            doIt = false
            audioPlayer.stop()
            UIApplication.shared.applicationIconBadgeNumber = 0;
            UIApplication.shared.cancelAllLocalNotifications()
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}

extension Date {
    
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        
        if minutes(from: date) >= 0 { return "\(minutes(from: date))" }
        if seconds(from: date) >= 0 { return "\(seconds(from: date))" }
        return ""
    }
}

