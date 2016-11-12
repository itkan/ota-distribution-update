//
//  CheckUpdateViewController.swift
//  ota
//
//  Created by Ankit Gupta on 11/12/16.
//  Copyright © 2016 ItKan. All rights reserved.
//

import UIKit

class CheckUpdateViewController: UIViewController {
    var currentBuildNumber = 1
    var featureName = "main"
    var apiaryUrl = ""
    var appdelegate:AppDelegate?
    var rootViewController:UIViewController?
    var application:UIApplication?
    var launchOptions:[UIApplicationLaunchOptionsKey: Any]?
    
    private struct Constants {
        struct responseKeys {
            static let latestBuildNumber = "latestBuildNumber"
            static let description = "description"
            static let url = "url"
        }
    }
    
    
    class func getViewController() -> CheckUpdateViewController {
        let storyBoard = UIStoryboard(name: "CheckUpdate", bundle: nil)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "CheckUpdateViewController") as! CheckUpdateViewController
        return viewController
    }
    
    func continueUpdate(url:URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: { flag in
            abort()
        })
    }
    
    func continueLaunching() {
        if let tAppdelegate = appdelegate, let tApplication = application, let tRootViewController = rootViewController {
            tAppdelegate.window?.rootViewController = tRootViewController
            tAppdelegate.window?.makeKeyAndVisible()
            _ = tAppdelegate.continueApplication(tApplication, didFinishLaunchingWithOptions: launchOptions)
        }
    }
    
    func checkUpdate() {
        
        guard let url = URL(string: "\(apiaryUrl)\(featureName)") else {
            continueLaunching()
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
            
            guard let tData = data else {
                self?.continueLaunching()
                return
            }
            
            do {
                
                guard let decodedJson = try JSONSerialization.jsonObject(with: tData, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> else {
                    self?.continueLaunching()
                    return
                }
                
                guard let update = Int(decodedJson[Constants.responseKeys.latestBuildNumber] as! String) else {
                    self?.continueLaunching()
                    return
                }
                
                guard let updateUrlServiceString = decodedJson[Constants.responseKeys.url] as? String else {
                    self?.continueLaunching()
                    return
                }
                
                let updateUrlString = "itms-services://?action=download-manifest&url=\(updateUrlServiceString)"
                
                guard let updateUrl = URL(string: updateUrlString) else {
                    self?.continueLaunching()
                    return
                }
                
                guard let tCurrentBuildNumber = self?.currentBuildNumber else {
                    self?.continueLaunching()
                    return
                }
                
                guard update > tCurrentBuildNumber else {
                    self?.continueLaunching()
                    return
                }
                
                
                // show a popup to user to update the build or do it later
                let alertController = UIAlertController(title: "Update!", message: decodedJson[Constants.responseKeys.description] as? String, preferredStyle: UIAlertControllerStyle.alert)
                
                let updateAction = UIAlertAction(title: "update", style: UIAlertActionStyle.default, handler: { [weak self] (action) in
                    self?.continueUpdate(url: updateUrl)
                })
                alertController.addAction(updateAction)
                
                let laterAction = UIAlertAction(title: "later", style: UIAlertActionStyle.cancel, handler: { [weak self] (action) in
                    self?.continueLaunching()
                })
                alertController.addAction(laterAction)
                
                self?.present(alertController, animated: true, completion: nil)
                
            }catch let error as NSError {
                print(error)
                self?.continueLaunching()
            }
        })
        
        dataTask.resume()
    }
    
    override func viewDidLoad() {
        checkUpdate()
    }
}
