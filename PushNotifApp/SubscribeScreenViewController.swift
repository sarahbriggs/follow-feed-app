//
//  SubscribeScreenViewController.swift
//  PushNotifApp
//
//  Created by Sarah Briggs on 7/19/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit


class SubscribeScreenViewController: UIViewController {
    let url = URL(string: "https://lit-gorge-55340.herokuapp.com/trader/index.json")!
    
    @IBOutlet weak var fauziaButton: UIButton!
    @IBOutlet weak var tomButton: UIButton!
    @IBOutlet weak var vonettaButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllTraders()
            .done { json -> Void in
                print(json)
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    
    @IBAction func subscribeToFauzia(_ sender: Any) {
        // post to API
        let curr_user = UserDefaults.standard.string(forKey: "user_id") ?? ""
        let curr_trader = getTraderId(traderName: "Fauzia")
        
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters = ["trader_id": curr_trader, "user_id": curr_user] as [String : Any]
        
        //create the url with URL
        let url = URL(string: "http://localhost:3000/subscription")! //change the url
        
        //create the session object
        let session = URLSession.shared
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        })
        task.resume()
    }
    
    func getTraderId(traderName: String) -> String {
        var trader_id = ""
        let parameters = ["name": traderName] as [String : Any]
        //create the url with URL
        
        let session = URLSession.shared
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if !responseJSON.isEmpty {
                    trader_id = responseJSON["id"] as! String
                    print(responseJSON)
                }
            }
        })
        task.resume()
        return trader_id
    }
    
    func getAllTraders() -> Promise<[[String: Any]]> {
        return Promise { promise in
            Alamofire.request (url, method: .get)
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    promise.fulfill(json as! [[String : Any]])
                case .failure(let error):
                    promise.reject(error)
                }
            }
        }
    }
}
