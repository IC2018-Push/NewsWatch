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

    let source = args["source"] as? String;
    let newsAPiKey = args["apiKey"] as? String;
    var result:[String:Any]?
    var str = "No response"
    var url = "/v1/articles?source="+source!+"&sortBy=top&apiKey="+newsAPiKey!;
    print(url)
    var requestOptions: [ClientRequest.Options] = []
    requestOptions.append(.method("GET"))
    requestOptions.append(.schema("https://"))
    requestOptions.append(.hostname("newsapi.org"))
    requestOptions.append(.path(url))

    let req = HTTP.request(requestOptions) { response in

        //if let response = response, response.statusCode == HTTPStatusCode.OK {

        do {
            str = try response!.readString()!
        } catch {
            print("Error \(error)")
        }
        // }

    }

    req.end()

    print("Got string \(str)")

    let data = str.data(using: String.Encoding.utf8, allowLossyConversion: true)!
    let json = JSON(data: data)
    if let jsonUrl = json["url"].string {
        print("Got json url \(jsonUrl)")
    } else {
        print("JSON DID NOT PARSE")
    }
    do {
        result = try JSONSerialization.jsonObject(with: data, options: [])  as? [String:Any]      } catch {
            print("Error \(error)")
    }

    // return, which should be a dictionary
    print("Result is \(result!)")
    return result!

}