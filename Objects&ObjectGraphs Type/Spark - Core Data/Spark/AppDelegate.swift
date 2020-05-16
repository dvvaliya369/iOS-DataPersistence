import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let managedObjectContext = persistentContainer.viewContext
        
        preloadEmployees(managedObjectContext: managedObjectContext)
        
        // Get the window's root view controller (which is a navigation controller)
        let navigationController = window?.rootViewController as! UINavigationController
        
        // Get the navigation controller's first view controller
        // Cast it to a InnovationIdeasViewController
        // Pass on the managed object context
        let firstVC = navigationController.viewControllers[0] as! InnovationIdeasViewController
        firstVC.managedObjectContext = managedObjectContext
        
        return true
    }

    func preloadEmployees(managedObjectContext: NSManagedObjectContext) {
        let employeeFetchRequest = NSFetchRequest<Employee>(entityName: Employee.entityName)
        
        do {
            let employees = try managedObjectContext.fetch(employeeFetchRequest)
            let employeesAlreadySeeded = employees.count > 0
            
            if(employeesAlreadySeeded == false) {
                let employee1 = NSEntityDescription.insertNewObject(forEntityName: Employee.entityName,
                                                                    into: managedObjectContext) as! Employee
                employee1.firstName = "Jane"
                employee1.lastName = "Sherman"
                employee1.department = "Accounting"
                
                let employee2 = NSEntityDescription.insertNewObject(forEntityName: Employee.entityName,
                                                                    into: managedObjectContext) as! Employee
                employee2.firstName = "Luke"
                employee2.lastName = "Jones"
                employee2.department = "Accounting"
                
                let employee3 = NSEntityDescription.insertNewObject(forEntityName: Employee.entityName,
                                                                    into: managedObjectContext) as! Employee
                employee3.firstName = "Kathy"
                employee3.lastName = "Smith"
                employee3.department = "Information Technology"
                
                let employee4 = NSEntityDescription.insertNewObject(forEntityName: Employee.entityName,
                                                                    into: managedObjectContext) as! Employee
                employee4.firstName = "Jerome"
                employee4.lastName = "Rodriguez"
                employee4.department = "Information Technology"
                
                let employee5 = NSEntityDescription.insertNewObject(forEntityName: Employee.entityName,
                                                                    into: managedObjectContext) as! Employee
                employee5.firstName = "Maria"
                employee5.lastName = "Tillman"
                employee5.department = "Legal"
                
                let employee6 = NSEntityDescription.insertNewObject(forEntityName: Employee.entityName,
                                                                    into: managedObjectContext) as! Employee
                employee6.firstName = "Paul"
                employee6.lastName = "Stevens"
                employee6.department = "Legal"
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print("Something went wrong: \(error)")
                    managedObjectContext.rollback()
                }
            }
        } catch {}
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

