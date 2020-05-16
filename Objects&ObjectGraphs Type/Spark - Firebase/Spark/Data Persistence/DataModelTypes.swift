import Foundation
import Firebase

struct Employee {
    var documentID: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var department: String = ""
    
    var firestoreDocument: [String : Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "department": department
        ]
    }
}

extension Employee {
    init?(documentID: String, firebaseDocument: [String : Any]) {
        guard
            let firstName = firebaseDocument["firstName"] as? String,
            let lastName = firebaseDocument["lastName"] as? String,
            let department = firebaseDocument["department"] as? String else { return nil }
        
        self.init(documentID: documentID, firstName: firstName, lastName: lastName, department: department)
    }
}

struct InnovationIdea {
    var documentID: String?
    var title: String = ""
    var ideaDescription: String  = ""
    var isDraft: Bool = true
    var dateSubmitted: Date?
    var submittedBy: String?
    var submitterEmailAddress: String?
    var submitterDepartment: String?
    var partnerID: String?
    var creationDate: Date?
    
    var firestoreDocument: [String : Any] {
        return [
            "title": title,
            "ideaDescription": ideaDescription,
            "isDraft": isDraft,
            "dateSubmitted": self.dateSubmitted != nil ? Timestamp(date: self.dateSubmitted!) : nil,
            "submittedBy": submittedBy ?? "",
            "submitterEmailAddress": submitterEmailAddress ?? "",
            "submitterDepartment": submitterDepartment ?? "",
            "partnerID": partnerID ?? "",
            "creationDate": self.creationDate != nil ? Timestamp(date: self.creationDate!) : nil
        ]
    }
}

extension InnovationIdea {
    init?(documentID: String, firebaseDocument: [String : Any]) {
        guard
            let title = firebaseDocument["title"] as? String,
            let ideaDescription = firebaseDocument["ideaDescription"] as? String,
            let isDraft = firebaseDocument["isDraft"] as? Bool
        else { return nil }
        
        let dateSubmittedTimestamp = firebaseDocument["dateSubmitted"] as? Timestamp
        let submittedBy = firebaseDocument["submittedBy"] as? String
        let submitterEmailAddress = firebaseDocument["submitterEmailAddress"] as? String
        let submitterDepartment = firebaseDocument["submitterDepartment"] as? String
        let partnerID = firebaseDocument["partnerID"] as? String
        let creationDateTimestamp = firebaseDocument["creationDate"] as? Timestamp
        
        let dateSubmitted = dateSubmittedTimestamp?.dateValue()
        let creationDate = creationDateTimestamp?.dateValue()
        
        self.init(documentID: documentID, title: title, ideaDescription: ideaDescription, isDraft: isDraft, dateSubmitted: dateSubmitted, submittedBy: submittedBy, submitterEmailAddress: submitterEmailAddress, submitterDepartment: submitterDepartment, partnerID: partnerID, creationDate: creationDate)
    }
}
