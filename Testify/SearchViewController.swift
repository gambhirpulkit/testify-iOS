//
//  SearchViewController.swift
//  Testify
//
//  Created by Pulkit Gambhir on 3/14/16.
//  Copyright © 2016 Pulkit Gambhir. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Haneke


class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var resultSearchController = UISearchController()
    
    @IBOutlet var viewFit: UIView!
    
    var reg_id: Int?
    
    var config = configUrl()
    var url : String?
    
    var searchCat = ""
    
    @IBOutlet var searchTable: UITableView!
    
    var userId = [String]()
    var username = [String]()
    var fName = [String]()
    var lName = [String]()
    var aboutUser = [String]()
    var imagePath = [String]()
    var followStatus = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        print("regId home",prefs.integerForKey("reg_id"))
        reg_id = prefs.integerForKey("reg_id")
        
        url = "http://testifyapp.org/app_serv/" + "new_v_api.php"
        print(url)
        
        // println(searchArr.count)
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = true
            controller.definesPresentationContext = true
            controller.searchBar.sizeToFit()
            controller.searchBar.placeholder = "Search for users & videos"
            //controller.searchBar.showsScopeBar = true
            controller.searchBar.scopeButtonTitles = ["Users", "Videos"]
            //     self.tableView.tableHeaderView = controller.searchBar
            self.viewFit.addSubview(controller.searchBar)
            
            return controller
        })()
        
        
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "Users") {

        if(scope == "Users") {
            
            if(searchText != "") {
                searchCat = scope
                findUserByName(searchText)
            }
            
        }
        else {
            if(searchText != "") {
                searchCat = scope
                findVideoByName(searchText)
            }
        }
        
        print("text",searchText)
        print("scope",scope)
    }
    
    func findUserByName(searchText: String) {
     
        print("searchTe",searchText)
        let param = ["do": "SearchbyUserString", "user_id": reg_id!, "find": searchText]
        
        Alamofire.request(.POST, url!, parameters: param as! [String : AnyObject]).responseString { (responseData) -> Void in
            
            //   let swiftyJsonVar = JSON(responseData.result.value!)
            
            //    print("jsonResponse" ,swiftyJsonVar);
            //   let resData = swiftyJsonVar["ResponseCode"].stringValue
            //   print(resData)
            print("responseData",responseData.result)
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse home" ,swiftyJsonVar);
                print("string",responseData.result.value!)
                let jsonString = responseData.result.value!
                if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    print(json["ResponseCode"])
                    let resData = json["ResponseCode"].intValue
                    
                    if(resData == 1) {
                        
                        for (key,subJson):(String, SwiftyJSON.JSON) in json["User_Details"] {
                            //Do something you want
                            print("testtt", subJson["username"].string)
                            if let vidData = subJson["username"].string {
                                self.username.append(vidData)
                                print("vidData",vidData)
                                
                            }
                            
                        }

                        
                        
                        
                        self.searchTable.reloadData()
                    }
                    else if(resData == 2) {
                    
                    let alert = UIAlertController(title: "No more search results", message:"Search Result Not Available", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                        // PERFORM ACTION
                        })
                    self.presentViewController(alert, animated: true){}
                    
                    }
                
                }
            case .Failure(let error):
                
                let alert = UIAlertController(title: "No internet connection", message:"Check your internet connection and try again.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                    // PERFORM ACTION
                    })
             //   self.presentViewController(alert, animated: true){}
                print(error)
            }
            
        } //END OF ALAMOFIRE
    }
    
    func findVideoByName(searchText: String) {
        
        print("searchTe",searchText)
        let param = ["do": "Video_SearchBy_Story", "story": searchText]
        
        Alamofire.request(.POST, url!, parameters: param)   .responseString { (responseData) -> Void in
            
            //   let swiftyJsonVar = JSON(responseData.result.value!)
            
            //    print("jsonResponse" ,swiftyJsonVar);
            //   let resData = swiftyJsonVar["ResponseCode"].stringValue
            //   print(resData)
            print("responseData",responseData.result)
            switch responseData.result {
            case .Success:
                let swiftyJsonVar = JSON(responseData.result.value!)
                
                print("jsonResponse home" ,swiftyJsonVar);
                print("string",responseData.result.value!)
                let jsonString = responseData.result.value!
                if let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                    print(json["ResponseCode"])
                    let resData = json["ResponseCode"].intValue
                    
                    if(resData == 1) {
                        
                        
                        self.searchTable.reloadData()
                    }
                    else if(resData == 2) {
                        
                        let alert = UIAlertController(title: "No more search results", message:"Search Result Not Available", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                            // PERFORM ACTION
                            })
                        self.presentViewController(alert, animated: true){}
                        
                    }
                    
                }
            case .Failure(let error):
                
                let alert = UIAlertController(title: "No internet connection", message:"Check your internet connection and try again.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in
                    // PERFORM ACTION
                    })
                //   self.presentViewController(alert, animated: true){}
                print(error)
            }
            
        } //END OF ALAMOFIRE

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cat",searchCat)
        
        if(searchCat == "Users") {
            return username.count
        }
        else if(searchCat == "Videos") {
            return 5
        }
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("usersCell")! as UITableViewCell
        if(searchCat == "Users") {
         
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = username[indexPath.row]
        }
            
        }
        return cell
        
    }
    
    
}

extension SearchViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}
