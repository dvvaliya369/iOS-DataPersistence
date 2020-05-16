import Foundation

struct Employee {
    let employeeID: Int
    let firstName: String
    let lastName: String
    let department: String
}

struct InnovationIdea {
    var innovationIdeaID: Int?
    var title: String
    var ideaDescription: String
    var isDraft: Bool
    var dateSubmitted: Date
    var submittedBy: String?
    var submitterEmailAddress: String?
    var submitterDepartment: String?
    var partnerEmployeeID: Int
    var creationDate: Date
}

let databaseDidSaveNotification = Notification.Name("com.pluralsight.spark.databaseDidSaveNotification")
let UpdatedObjectKey = "UpdatedObjectKey"
