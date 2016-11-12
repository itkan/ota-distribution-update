# ota-distribution-update


Do you need this? if below questions make sense to you, then Yes.
- are you developing multiple features simultaneously?
- for each feature do you create separate builds to test?
- do you have to provide build updates for each feature separately?

I used following items to solve my problem:
- https://apiary.io account
- https://www.dropbox.com account

This project is in Swift 3.0, let me know if you need help

How to use this code:

Step 1:
- Add ota/CheckUpdate files to your project

Step 2: update AppDelegate file

change code from 

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // there can be lot of lines here, we will move this to new location
        return true
    }

```

to 

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            let launchController = CheckUpdateViewController.getViewController()
            launchController.currentBuildNumber = 1
            launchController.featureName = "feature1"
            launchController.apiaryUrl = "https://private-1bb4d9-itkan1.apiary-mock.com/builds/"
            launchController.appdelegate = self
            launchController.application = application
            launchController.launchOptions = launchOptions
            launchController.rootViewController = window?.rootViewController
            window?.rootViewController = launchController
            window?.makeKeyAndVisible()
        #endif
        
        let result = continueApplication(application, didFinishLaunchingWithOptions: launchOptions)
        return result
    }
    
    @nonobjc func continueApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // there can be lot of lines here, we will move this to new location. Yes this is new location
        return true
    }
```
