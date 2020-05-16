import Foundation
import CloudKit

struct Employee {
    var firstName: String
    var lastName: String
    var department: String
    
    public var encodedSystemFields: Data

    init(record: CKRecord) {
        self.firstName = record["firstName"] as! String
        self.lastName = record["lastName"] as! String
        self.department = record["department"] as! String
        
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        self.encodedSystemFields = coder.encodedData
    }
    
    var cloudKitRecord: CKRecord {
        var employee: CKRecord
        
        let decoder = try! NSKeyedUnarchiver(forReadingFrom: self.encodedSystemFields)
        decoder.requiresSecureCoding = true
        employee = CKRecord(coder: decoder)!
        decoder.finishDecoding()
        
        return employee
    }
}

struct InnovationIdea {
    var title: String
    var ideaDescription: String
    var isDraft: Bool
    var dateSubmitted: Date?
    var submittedBy: String?
    var submitterEmailAddress: String?
    var submitterDepartment: String?
    var partner: CKRecord.Reference?
    
    public var creationDate: Date? // assigned by iCloud
    public var modificationDate: Date? // assigned by iCloud
    
    public var encodedSystemFields: Data?

    init(title: String,
         ideaDescription: String,
         isDraft: Bool,
         dateSubmitted: Date?,
         submittedBy: String?,
         submitterEmailAddress: String?,
         submitterDepartment: String?,
         partner: CKRecord.Reference?) {
        
        self.title = title
        self.ideaDescription = ideaDescription
        self.isDraft = isDraft
        self.dateSubmitted = dateSubmitted
        self.submittedBy = submittedBy
        self.submitterEmailAddress = submitterEmailAddress
        self.submitterDepartment = submitterDepartment
        self.partner = partner
    }
    
    init(record: CKRecord) {
        let coder = NSKeyedArchiver(requiringSecureCoding: true)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        self.encodedSystemFields = coder.encodedData
        
        self.title = record["title"] as! String
        self.ideaDescription = record["ideaDescription"] as! String
        self.isDraft = record["isDraft"] as! Bool
        self.dateSubmitted = record["dateSubmitted"] as? Date
        self.submittedBy = record["submittedBy"]
        self.submitterEmailAddress = record["submitterEmailAddress"]
        self.submitterDepartment = record["submitterDepartment"]
        self.partner = record["partner"] as? CKRecord.Reference
        
    }
    
    var cloudKitRecord: CKRecord {
        var innovationIdea: CKRecord
        
        if let systemFields = self.encodedSystemFields {
            // Decoder --> CKRecord
            let decoder = try! NSKeyedUnarchiver(forReadingFrom: systemFields)
            decoder.requiresSecureCoding = true
            innovationIdea = CKRecord(coder: decoder)!
            decoder.finishDecoding()
        } else {
            innovationIdea = CKRecord(recordType: "InnovationIdea")
        }
        
        innovationIdea["title"] = self.title as NSString
        innovationIdea["ideaDescription"] = self.ideaDescription as NSString
        innovationIdea["isDraft"] = self.isDraft as NSNumber
        innovationIdea["dateSubmitted"] = self.dateSubmitted
        innovationIdea["submittedBy"] = self.submittedBy as NSString?
        innovationIdea["submitterEmailAddress"] = self.submitterEmailAddress as NSString?
        innovationIdea["submitterDepartment"] = self.submitterDepartment as NSString?
        innovationIdea["partner"] = self.partner
        
        return innovationIdea
    }
}

let recordDidChangeLocally = Notification.Name("com.pluralsight.spark.localChangeKey")
let recordDidChangeRemotely = Notification.Name("com.pluralsight.spark.remoteChangeKey")

enum RecordChange {
    case created(CKRecord)
    case updated(CKRecord)
    case deleted(CKRecord.ID)
}
