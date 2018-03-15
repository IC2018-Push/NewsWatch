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

//Push Service credentials
let appSecret = " PuPush Servicsh AppSecret"
let clientSecret = "Push Servic Clientsecret"
let appID = "Push Servich appGUID"
let appRegion = "push App region"  

// Watson translator Credentials
let translatorUsername = "Watson translator username"
let translatorPassword = "Watson translator password"

//News API Key
let newsAPIKey = "7a563830-7222-466c-8b84-ca23b29aab8f"

public enum LanguageEnum: String {
    
    case en = "English", es = "Spanish", ko = "Korean", nl = "Dutch", fr = "French", it = "Italian", de = "German", js = "Japanese", zh = "Chinese", tr = "Turkish", pl = "Polish", pt = "Portuguese", ru = "Russian", ar = "Arabic"
    
}
func getTranslated(txt: String, toLanguage:String) -> String {
  if (!txt.isEmpty){
      let toLang = String(describing: LanguageEnum(rawValue: toLanguage)!)
  let invokeResult = Whisk.invoke(actionNamed:"/whisk.system/watson-translator/translator",withParameters:["username":translatorUsername,"password":translatorPassword,"payload":txt,"translateFrom":"en","translateTo":toLang])
  let dateActivation = JSON(invokeResult)   
  return(dateActivation["response"]["result"]["payload"].string)!
  } else {
      return ""
  }
}

func getNews(tag:String) -> JSON {

    var response1:JSON = [:]
    var url = "/filterWebContent?token="+newsAPIKey+"&format=json&ts=1520889786731&sort=relevancy&q="+tag
    var requestOptions1: [ClientRequest.Options] = []
    requestOptions1.append(.method("GET"))
    requestOptions1.append(.schema("https://"))
    requestOptions1.append(.hostname("webhose.io"))
    requestOptions1.append(.path(url))
    let req1 = HTTP.request(requestOptions1) { resp in
        do {
            var body = Data()
            try resp?.readAllData(into: &body)
            response1 = JSON(data: body)
            // response1 = response1["posts"]
            // if response1.count > 0  {
            //     let j = response1[0]["thread"]                
            //     let messages = j["title"].stringValue
            //     let description = j["title_full"].stringValue
            //     let newsURL = response1[0]["url"].stringValue;
            //     let dd = ["data":description,"newsURL":newsURL]

            // }
        } catch {
            print("Error get message")
        }
    }
    req1.end()

    return response1
}

func sendNotification(newsTag: String, languageTag:String, devices:[String]) {

   var neswjson = getNews(tag:newsTag);
   neswjson = neswjson["posts"]
    if neswjson.count > 0  {
        let j = neswjson[0]["thread"]                
        var messages = j["title"].stringValue
        var description = j["title_full"].stringValue
        let newsURL = neswjson[0]["url"].stringValue;        
        if (languageTag != "English") {
           messages = getTranslated(txt: messages, toLanguage:languageTag)
           description = getTranslated(txt: description, toLanguage:languageTag)
        }
        let dd = ["data":description,"newsURL":newsURL]

        let resss = Whisk.invoke(actionNamed:"/whisk.system/pushnotifications/sendMessage",withParameters:["appSecret":appSecret,"appId":appID,"text":messages,"apnsPayload":dd,"apnsType":"MIXED","deviceIds":devices])
        print(resss)
    }
}

func getDevices(tag : String) -> [String] {

var devices = [String]()
var requestOptions: [ClientRequest.Options] = []
    requestOptions.append(.method("GET"))
    requestOptions.append(.schema("https://"))
    requestOptions.append(.hostname("imfpush\(appRegion)"))
    requestOptions.append(.path("/imfpush/v1/apps/\(appID)/subscriptions?expand=false&tagName=\(tag)"))
    requestOptions.append(.headers(["clientSecret":clientSecret]))
    
    
    let req = HTTP.request(requestOptions) { resp in
        if let resp = resp, resp.statusCode == HTTPStatusCode.OK {
            do {
                var body = Data()
                try resp.readAllData(into: &body)
                let response = JSON(data: body)
                let tagsRes = response["subscriptions"]
                if tagsRes.count > 0 {
                    for (index, threads) in tagsRes {

                         let j = threads["deviceId"].stringValue  
                         devices.append(j);
                }
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
        return devices
}

func main(args: [String:Any]) -> [String:Any] {
    
    
    //Add Your credentials
     
    
    let languageTags = [
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
        ];

    let newsTags = [
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


  //let  values = getDevices(tag:"Spanish");
    
  for newsTag in newsTags {
        
        let  values = getDevices(tag:newsTag);
        if (values.count > 0) {
            for languageTag in languageTags {
   
           let  values1 = getDevices(tag:languageTag);
           if (values1.count > 0) {
               let devices = values1.filter{ values.contains($0) }
               sendNotification(newsTag:newsTag, languageTag:languageTag, devices:devices)
           }
        }
        }        
  }
        return [ "greeting" : "th" ]
}
