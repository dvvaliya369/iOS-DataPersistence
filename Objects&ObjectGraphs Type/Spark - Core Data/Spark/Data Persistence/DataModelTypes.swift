import Foundation
import CoreData

class Employee: NSManagedObject {
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var department: String
    
    static var entityName: String { return "Employee" }
}

class InnovationIdea: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var ideaDescription: String
    @NSManaged var isDraft: Bool
    @NSManaged var dateSubmitted: Date
    @NSManaged var submittedBy: String?
    @NSManaged var submitterEmailAddress: String?
    @NSManaged var submitterDepartment: String?
    @NSManaged var partner: Employee?
    @NSManaged var creationDate: Date
    
    static var entityName: String { return "InnovationIdea" }

}

let databaseDidSaveNotification = Notification.Name("com.pluralsight.spark.databaseDidSaveNotification")
let UpdatedObjectKey = "UpdatedObjectKey"
