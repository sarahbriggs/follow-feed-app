//
//  LoginViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 7/19/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailBox: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func buttonClick(_ sender: Any) {
        let parameters = ["email": emailBox.text!] as [String : Any]
        //create the url with URL
        let url = URL(string: "http://localhost:3000/sessions")! //change the url
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
                if !responseJSON.isEmpty {
                    let user_id = responseJSON["user_id"]
                    DispatchQueue.main.async{
                        UserDefaults.standard.set(user_id, forKey: "user_id")
                        self.performSegue(withIdentifier: "loginSuccess", sender: self)
                    }
                }
                else {
                    DispatchQueue.main.async{
                        self.emailBox.text = ""
                        self.emailBox.placeholder = "Try again"
                    }
                }
            }
        })
        task.resume()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
