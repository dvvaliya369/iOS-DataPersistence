import Foundation
import RealmSwift

class Employee: Object {
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var department: String = ""
}

class InnovationIdea: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var ideaDescription: String  = ""
    @objc dynamic var isDraft: Bool = true
    @objc dynamic var dateSubmitted: Date?
    @objc dynamic var submittedBy: String?
    @objc dynamic var submitterEmailAddress: String?
    @objc dynamic var submitterDepartment: String?
    @objc dynamic var partner: Employee?
    @objc dynamic var creationDate: Date = Date()
    
    convenience init(title: String,
                     ideaDescription: String,
                     isDraft: Bool,
                     dateSubmitted: Date?,
                     submittedBy: String?,
                     submitterEmailAddress: String?,
                     submitterDepartment: String?,
                     partner: Employee?,
                     creationDate: Date) {
        
        self.init()
        
        self.title = title
        self.ideaDescription = ideaDescription
        self.isDraft = isDraft
        self.dateSubmitted = dateSubmitted
        self.submittedBy = submittedBy
        self.submitterEmailAddress = submitterEmailAddress
        self.submitterDepartment = submitterDepartment
        self.partner = partner
        self.creationDate = creationDate
    }
}
