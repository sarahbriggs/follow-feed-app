//
//  ViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 7/17/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit

let user_id = "0"

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var emailBox: UITextField!
    @IBOutlet weak var nameBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goClicked(_ sender: Any) {
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
        let parameters = ["name": nameBox.text!, "email": emailBox.text!] as [String : Any]
        //create the url with URL
        let url = URL(string: "http://localhost:3000/users")! //change the url
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
}

