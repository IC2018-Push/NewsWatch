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

func main(args: [String:Any]) -> [String:Any] {

    let searchKey = args["searchKey"] as? String;
    let language = args["language"] as? String;
    let location = args["location"] as? String;
    let convertLanguage = args["convertLanguage"] as? String;

    var str = "No response"
    var response: JSON?
    var result = [[String:String]]();
    var url = "/filterWebContent?token="+newsAPIKey+"&format=json&sort=crawled&q="+searchKey!+"%20language:"+language!+"%20location:"+location!;
    var requestOptions: [ClientRequest.Options] = []
    requestOptions.append(.method("GET"))
    requestOptions.append(.schema("https://"))
    requestOptions.append(.hostname("webhose.io"))
    requestOptions.append(.path(url))

    let req = HTTP.request(requestOptions) { resp in


        do {
            var body = Data()
            try resp?.readAllData(into: &body)
            var response1 = JSON(data: body)
            response1 = response1["posts"]
           // print(response1)
            if response1.count > 0  {
            var count = 0;
                for (index, threads) in response1 {
                   
                    let j = threads["thread"]  
                    var news:[String:String] = [:]
                     if(count <= 10 && j["main_image"].stringValue != "") {
                    news["title"] = j["title"].stringValue;
                    news["publishedAt"] = j["published"].stringValue;
                    news["urlToImage"] = j["main_image"].stringValue;
                    news["section_title"] = j["section_title"].stringValue;
                    news["description"] = threads["text"].stringValue;
                    news["url"] = threads["url"].stringValue;

                    if (convertLanguage != "English") {
                        news["title"] = getTranslated(txt: (news["title"])!, toLanguage:convertLanguage!)
                        news["section_title"] = getTranslated(txt: (news["section_title"])!, toLanguage:convertLanguage!)
                        news["description"] = getTranslated(txt: (news["description"])!, toLanguage:convertLanguage!)
                    }
                    
                    result.append(news);
                    count+=1;
                    }
                } 
            } else {
                print("Error Empty data")
            }
        } catch {
            print("Error ")
        }

    }

    req.end()
    return ["result":result]

}