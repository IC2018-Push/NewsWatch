////: Playground - noun: a place where people can play
//
//import UIKit
//
//var str = "Hello, playground"
//
//
// var dateString = "2018-03-10T18:51:00.000+02:00"
//dateString = String(dateString[dateString.startIndex..<dateString.index(dateString.startIndex, offsetBy: 19)]) // prints: ful
//
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//    dateFormatter.locale = Locale.init(identifier: "en_GB")
//    let dateObj = dateFormatter.date(from: dateString)
//
//    dateFormatter.dateFormat = "hh:mm a"
//    let hjksfdf = (dateFormatter.string(from: dateObj!))
//
////
////    let calendar = NSCalendar.autoupdatingCurrent
////    let someDate:Date = dateObj!
////    if calendar.isDateInYesterday(someDate as Date) {
////        let jfskhdfjsd = "Yesterday"
////    }
////    else if calendar.isDateInToday(someDate as Date) {
////        let sk = "Today"
////    }
////    else{
////        dateFormatter.dateFormat = "MMM dd yyyy"
////        let kjkhj = (dateFormatter.string(from: dateObj!))
////    }
//



/**
 *
 * main() will be invoked when you Run This Action.
 *
 * @param OpenWhisk actions accept a single parameter,
 *        which must be a JSON object.
 *
 * In this case, the params variable will look like:
 *     { "message": "xxxx" }
 *
 * @return which must be a JSON object.
 *         It will be the output of this action.
 *
 */

import KituraNet
import Foundation
import SwiftyJSON

func main(args: [String:Any]) -> [String:Any] {
    
    
    //Add Your credentials
    let appSecret = "b6bf9b02-261a-4e3b-bbe2-886aacabf959"
    let appID = "21e0805e-f57c-4077-a5f9-172a2ca0b451"
    let appRegion = ".ng.bluemix.net"
    
    let newsAPIKey = "7a563830-7222-466c-8b84-ca23b29aab8f"
    
    
    var str = 0
    var values = 0
    
    var requestOptions: [ClientRequest.Options] = []
    requestOptions.append(.method("GET"))
    requestOptions.append(.schema("https://"))
    requestOptions.append(.hostname("imfpush\(appRegion)"))
    requestOptions.append(.path("/imfpush/v1/apps/\(appID)/tags"))
    requestOptions.append(.headers(["appSecret":appSecret]))
    
    
    let req = HTTP.request(requestOptions) { resp in
        if let resp = resp, resp.statusCode == HTTPStatusCode.OK {
            do {
                var body = Data()
                try resp.readAllData(into: &body)
                let response = JSON(data: body)
                str = response["tags"].count
                str = str - 1
                
                while(str>=0){
                    let tag =  response["tags"][str]["name"].string
                    var url = "/filterWebContent?token="+newsAPIKey+"&format=json&ts=1520889786731&sort=relevancy&q="+tag!
                    var requestOptions1: [ClientRequest.Options] = []
                    requestOptions1.append(.method("GET"))
                    requestOptions1.append(.schema("https://"))
                    requestOptions1.append(.hostname("webhose.io"))
                    requestOptions1.append(.path(url))
                    str = str - 1;
                    
                    let req1 = HTTP.request(requestOptions1) { resp in
                        
                        do {
                            var body = Data()
                            try resp?.readAllData(into: &body)
                            var response1 = JSON(data: body)
                            response1 = response1["posts"]
                            if response1.count > 0  {
                                let j = response1[0]["thread"]
                                
                                print(j["title_full"].stringValue)
                                
                                let messages = j["title"].stringValue
                                let description = j["title_full"].stringValue
                                let newsURL = response1[0]["url"].stringValue;
                                let dd = ["data":description,"newsURL":newsURL]
                                let resss = Whisk.invoke(actionNamed:"/whisk.system/pushnotifications/sendMessage",withParameters:["appSecret":appSecret,"appId":appID,"text":messages,"apnsPayload":dd,"apnsType":"MIXED","tagNames":[tag!]])
                                print(resss)
                                
                            }
                        } catch {
                            print("Error ")
                        }
                    }
                    req1.end()
                    }
                    
                } catch {
                    print("Error parsing JSON fromresponse")
                }
            } else {
                if let resp = resp {
                    //request failed
                    print("Error ; status code \(resp.statusCode) returned")
                } else {
                    print("Error")
                }
            }
        }
        
        req.end()
        
        return [ "greeting" : values ]
}
