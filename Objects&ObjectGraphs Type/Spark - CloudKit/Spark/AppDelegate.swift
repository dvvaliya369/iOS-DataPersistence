import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let publicCloudDatabase = CKContainer.default().publicCloudDatabase
        
        subscribeToCloudKitNotifications()
        application.registerForRemoteNotifications()

        // Get the window's root view controller (which is a navigation controller)
        let navigationController = window?.rootViewController as! UINavigationController
        
        // Get the navigation controller's first view controller
        // Cast it to a InnovationIdeasViewController and return
        // Pass on the CloudKit database
        let firstVC = navigationController.viewControllers[0] as! InnovationIdeasViewController
        firstVC.publicCloudDatabase = publicCloudDatabase
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCenter.default.post(name: recordDidChangeRemotely, object: self, userInfo: userInfo)
    }
    
    func subscribeToCloudKitNotifications() {
        // Which type of record?
        // Which ones?
        // When?  When they're created? updated? deleted? all of the above?
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKQuerySubscription(recordType: "InnovationIdea",
                                               predicate: predicate,
                                               options: [.firesOnRecordCreation,
                                                         .firesOnRecordUpdate,
                                                         .firesOnRecordDeletion])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription],
                                                       subscriptionIDsToDelete: nil)
        
        operation.modifySubscriptionsCompletionBlock = { savedSubscriptions, deletedSubscriptionIDs, error in
            // TODO: Cache that the subscription was saved so that we don't recreate it every time the app launches...
        }
        
        operation.qualityOfService = .utility
        
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

