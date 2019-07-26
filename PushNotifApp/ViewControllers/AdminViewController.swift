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

class AdminViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popOver: UIView!
    let tradersUrl = "/trader.json"
    var allTraders = [String]()
    var allTraderIds = [Int]()
    var deleteThisTrader = -1
    
    //MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        getAllTraders()
        popOver.isHidden = true
    }
    
    
    func getAllTraders() {
        allTraders.removeAll()
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
    
    func deleteTrader() {
        apiDeleteTrader()
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
    
    // MARK: - API Calls
    func apiGetAllTraders() -> Promise<[[String: Any]]> {
        let url = URL(string: ConstantsEnum.baseUrl+tradersUrl)!
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
    
    func apiPostNewTrader() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+tradersUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .post, parameters: ["name":nameField.text!])
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
    
    func apiDeleteTrader() -> Promise<[String: Any]> {
        let url = URL(string: ConstantsEnum.baseUrl+tradersUrl)!
        return Promise { promise in
            Alamofire.request (url, method: .delete, parameters: ["id":deleteThisTrader])
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
        deleteThisTrader = allTraderIds[indexPath.row]
    }
    
    //MARK: - Actions
    @IBAction func goClicked(_ sender: Any) {
        postNewTrader()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        popOver.isHidden = true
    }
    @IBAction func yesClicked(_ sender: Any) {
        deleteTrader()
    }
}
