# ota-distribution-update


Do you need this? if below questions make sense to you, then Yes.
- are you developing multiple features simultaneously?
- for each feature do you create separate builds to test?
- do you have to provide build updates for each feature separately?

I used following items to solve my problem:
- https://apiary.io - host a static web service
- https://www.dropbox.com - upload builds (ipa files)
- http://github.com - source code / apiary integration

## Quick Integration:

**Step 1:**
- Add [ota/ota/CheckUpdate](https://github.com/itkan/ota-distribution-update/tree/master/ota/ota/CheckUpdate) files to your project

**Step 2:** update AppDelegate file

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

**Step 3:** Log in to your apiary.io account then copy and paste below code in its editor
```
FORMAT: 1A
HOST: http://polls.apiblueprint.org/

# App update

## feature1 [/builds/feature1]
### update [GET]
+ Response 200 (application/json)

        {"latestBuildNumber":"2","url":"https://dl.dropboxusercontent.com/s/dssss/manifest.plist","description":"description about latest update"} 
```
- in the last line of above code is a json, which will be read by app
    - latestBuildNumber - put your latest build number i.e. 2 for this sample
    - url - put the direct dropbox url of your manifest file
    - description - put what has been updated in the new build
- copy the mock url from apiary and update the below line removing the feature name from end
```
launchController.apiaryUrl = "https://private-1bb4d9-itkan1.apiary-mock.com/builds/"
```

**Step 4:** create first build of new feature
- in didFinishLaunchingWithOptions method set currentBuildNumber to 1 as below
```swift
    launchController.currentBuildNumber = 1 
```
- Build an ipa with manifest file and save it in your dropbox at following path
    - /builds/feature1/1/myapp.ipa
    - /builds/feature1/1/manifest.plist
    - /builds/feature1/1/index.html
        - sample manifest.plist / index.html files are added in extras folder for your ease. You have to update urls in these files to make them work for your app.
- send the link to index.html to your targets for installation of first build.

**Step 5:** create another build of same feature
- in didFinishLaunchingWithOptions method set currentBuildNumber to 2 as below
```swift
    launchController.currentBuildNumber = 2 
```
- Build an ipa with manifest file and save it in your dropbox at following path
    - /builds/feature1/2/myapp.ipa
    - /builds/feature1/2/manifest.plist
    - now you dont need any other index file
    

**Step 6:** Now everytime you restart your build 1 a pop-up will appear to install the latest build or do it later, if user taps for update another confirmation is made from user and app is killed to install the latest app. From this way, you never have to communicate the QA / UAT team that new build is available since they will automatically get to know that, when they use build.

### Good to do:
1. if you integrate apiary.io with your git repository as I have done in this one, you can update the apiary.io from your code editor itself and when you push your commit the API is automatically updated.
1. Also instead of using index.html file, host a static website where user can find all the feature builds at one place, and you can eliminate the step of sending link.

**Note:**
- This project is in Swift 3.0, let me know if you need help


