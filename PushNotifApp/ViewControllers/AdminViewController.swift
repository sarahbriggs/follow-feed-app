//
//  AdminViewController.swift
//  PushNotifApp
//
//  Created by Carolyn Blumberg on 7/26/19.
//  Copyright © 2019 Carolyn Blumberg. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popOver: UIView!
    @IBOutlet weak var traderLabel: UILabel!
    var allTraders = [String]()
    var allTraderIds = [Int]()

    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        nameField.delegate = self
        popOver.isHidden = true
        getAllTraders()
    }
    
    
    func getAllTraders() {
        allTraders.removeAll()
        allTraderIds.removeAll()
        apiGetAllTraders()
            .done { json -> Void in
                for dict in json {
                    let name = dict["name"] as! String
                    let id = dict["id"] as! Int
                    self.allTraders.append(name)
                    self.allTraderIds.append(id)
                }
                self.tableView.reloadData()
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func postNewTrader() {
        apiPostNewTrader()
            .done { json -> Void in
                if !json.isEmpty {
                    self.nameField.text = ""
                    self.nameField.placeholder = "Trader added"
                    self.getAllTraders()
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    func deleteTrader(traderId: Int) {
        apiDeleteTrader(traderId: traderId)
            .done { json -> Void in
                if json["deleted"] as! Bool == true {
                    self.getAllTraders()
                    self.popOver.isHidden = true
                }
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "publishMessage" {
            let vc = segue.destination as! MessageViewController
            vc.traderId = publishButton.tag
        }
    }
    
    // MARK: - API Calls
    func apiGetAllTraders() -> Promise<[[String: Any]]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.tradersUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .get)
                .validate()
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
    
    func apiPostNewTrader() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.tradersUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["name":nameField.text!])
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        promise.fulfill(json as! [String : Any])
                    case .failure(let error):
                        promise.reject(error)
                    }
            }
        }
    }
    
    func apiDeleteTrader(traderId: Int) -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+ConstantsEnum.tradersUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .delete, parameters: ["id":traderId])
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        promise.fulfill(json as! [String : Any])
                    case .failure(let error):
                        promise.reject(error)
                    }
            }
        }
    }
    
    //MARK: - Tableview funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTraders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TraderCell")
        cell?.textLabel?.text = allTraders[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        popOver.isHidden = false
        traderLabel.text = "Trader: " + allTraders[indexPath.row]
        deleteButton.tag = allTraderIds[indexPath.row]
        publishButton.tag = allTraderIds[indexPath.row]
    }
    
    //MARK: - Actions
    @IBAction func goClicked(_ sender: Any) {
        postNewTrader()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        popOver.isHidden = true
    }
    @IBAction func yesClicked(_ sender: UIButton) {
        deleteTrader(traderId: sender.tag)
    }
    @IBAction func publishClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "publishMessage", sender: self)
    }
}
