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

    let newsAPiKey = args["apiKey"] as? String;
    let searchKey = args["searchKey"] as? String;
    let language = args["language"] as? String;
    let location = args["location"] as? String;
    
    print(newsAPiKey!)
    print(searchKey!)
    print(language!)
    print(location!)
    
    
    
    
    // let newsAPiKey = "7a563830-7222-466c-8b84-ca23b29aab8f";
    // let searchKey = "International news";
    // let language = "english";
    // let location = "newyork";
    
    
    var str = "No response"
    var response: JSON?
    var result = [[String:String]]();
    var url = "/filterWebContent?token="+newsAPiKey!+"&format=json&sort=crawled&q="+searchKey!+"%20language:"+language!+"%20location:"+location!;
    print(url)
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


    // let data = str.data(using: String.Encoding.utf8, allowLossyConversion: true)!
    // let json = JSON(data: data)
    // if let jsonUrl = json["url"].string {
    //     print("Got json url \(jsonUrl)")
    // } else {
    //     print("JSON DID NOT PARSE")
    // }
    // do {
    //     result = try JSONSerialization.jsonObject(with: data, options: [])  as? [String:Any]      } catch {
    //         print("Error \(error)")
    // }

    // // return, which should be a dictionary
   // print("Result is \(response!)")
    //return ["result":result]
    return ["result":result]

}