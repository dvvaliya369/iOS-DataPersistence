import UIKit
import CloudKit

class InnovationIdeaEditorViewController:   UIViewController,
                                            UIPickerViewDataSource,
                                            UIPickerViewDelegate {

    var publicCloudDatabase: CKDatabase!
    
    var innovationIdea: InnovationIdea?

	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var partnerPicker: UIPickerView!
    
    var partners: [Employee]?
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		descriptionTextView.layer.borderWidth = CGFloat(0.5)
		descriptionTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
		descriptionTextView.layer.cornerRadius = 5
		descriptionTextView.clipsToBounds = true
        
        self.partnerPicker.dataSource = self
        self.partnerPicker.delegate = self

        self.loadPartners()
        self.setUIValues()
	}

    func setUIValues() {
        guard let innovationIdea = self.innovationIdea else { return }
        
        self.titleTextField.text = innovationIdea.title
        self.descriptionTextView.text = innovationIdea.ideaDescription
        
        // partnerPicker is populated asynchronously, so setting this UI value
        // happens in the loadPartners() function
    }
    
    func loadPartners() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let employeeQuery = CKQuery(recordType: "Employee", predicate: predicate)
        
        let primarySortDescriptor = NSSortDescriptor(key: "lastName",
                                                     ascending: true)
        
        let secondarySortDescriptor = NSSortDescriptor(key: "lastName",
                                              ascending: true)
        
        employeeQuery.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        publicCloudDatabase.perform(employeeQuery,
                                                          inZoneWith: nil)
        { (records, error) in
            guard let records = records else {return}
            
            DispatchQueue.main.async {
                self.partners = records.map { Employee(record:$0) }

                var selectedPartnerIndex = 0
                
                if let partner = self.innovationIdea?.partner, let partners = self.partners {
                    selectedPartnerIndex = partners.firstIndex(where: { (employee) -> Bool in
                        employee.cloudKitRecord.recordID.recordName == partner.recordID.recordName
                    }) ?? 0
                }
                
                self.partnerPicker.reloadAllComponents()
                self.partnerPicker.selectRow(selectedPartnerIndex, inComponent: 0, animated: false)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
	
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let partner = self.partners?.count ?? 0 > 0 ? self.partners?[self.partnerPicker.selectedRow(inComponent: 0)] : nil
        
        var partnerReference: CKRecord.Reference? = nil
        
        if let p = partner {
            partnerReference = CKRecord.Reference(recordID: p.cloudKitRecord.recordID,
                                                  action: .none)
        }
        
        if var editedInnovationIdea = self.innovationIdea {
            editedInnovationIdea.title = titleTextField.text ?? ""
            editedInnovationIdea.ideaDescription = descriptionTextView.text
            editedInnovationIdea.isDraft = true
            editedInnovationIdea.partner = partnerReference
            
            self.saveInnovationIdeaRecord(editedInnovationIdea.cloudKitRecord)
        } else {
            let newIdea = InnovationIdea(title: titleTextField.text ?? "",
                                                ideaDescription: descriptionTextView.text,
                                                isDraft: true,
                                                dateSubmitted: nil,
                                                submittedBy: nil,
                                                submitterEmailAddress: nil,
                                                submitterDepartment: nil,
                                                partner: partnerReference)
      
            self.publicCloudDatabase.save(newIdea.cloudKitRecord) { (savedRecord, error) in
                guard let createdRecord = savedRecord else { return }
                
                NotificationCenter.default.post(name: recordDidChangeLocally,
                                                object: self,
                                                userInfo: ["recordChange" : RecordChange.created(createdRecord)])
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveInnovationIdeaRecord(_ innovationIdea: CKRecord) {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [innovationIdea],
                                                       recordIDsToDelete: nil)
        
        modifyOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in            
            if let cloudKitError = error as? CKError {
                switch cloudKitError.code {
                // Fatal errors
                case .internalError, .serverRejectedRequest, .invalidArguments, .permissionFailure:
                    let alert = UIAlertController(
                        title: "Could Not Save",
                        message: "The hazard report couldn't be saved due to a problem with iCloud. Please try again later.",
                        preferredStyle: UIAlertController.Style.alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                // Unavailable state errors
                case .networkUnavailable, .notAuthenticated:
                    // .notAuthenticated is more for the private cloud database... will ignore for HazardReporter
                    let alert = UIAlertController(title: "Could Not Connect", message: "Please try again when you have an Internet connection.", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    self.present(alert, animated: true, completion: nil)
                    // Monitor for reachability; Retry once an Internet connection is available
                    
                // Retry errors
                case .zoneBusy, .serviceUnavailable, .requestRateLimited:
                    if let retryAfterDuration = cloudKitError.userInfo[CKErrorRetryAfterKey] as? Double {
                        let retryTime = DispatchTime.now() + retryAfterDuration
                        
                        DispatchQueue.main.asyncAfter(deadline: retryTime, execute: {
                            self.saveInnovationIdeaRecord(innovationIdea)
                        })
                    }
                // Server record change conflicts
                case .partialFailure:
                    guard let partialErrorDictionary = cloudKitError.userInfo[CKPartialErrorsByItemIDKey] as? [CKRecord.ID:NSError] else { break }
                    guard let partialError = partialErrorDictionary.first?.value as? CKError else { break }
                    
                    switch partialError.code {
                    case .serverRecordChanged:
                        // Get server record and client record from userInfo dictionary
                        let serverRecord = partialError.userInfo[CKRecordChangedErrorServerRecordKey] as! CKRecord
                        let clientRecord = partialError.userInfo[CKRecordChangedErrorClientRecordKey] as! CKRecord
                        
                        // Merge changes from client to server record
                        serverRecord["title"] = clientRecord["title"]
                        serverRecord["ideaDescription"] = clientRecord["ideaDescription"]
                        serverRecord["isDraft"] = clientRecord["isDraft"]
                        serverRecord["dateSubmitted"] = clientRecord["dateSubmitted"]
                        serverRecord["submittedBy"] = clientRecord["submittedBy"]
                        serverRecord["submitterEmailAddress"] = clientRecord["submitterEmailAddress"]
                        serverRecord["submitterDepartment"] = clientRecord["submitterDepartment"]
                        serverRecord["partner"] = clientRecord["partner"]
                        
                        // Re-save
                        self.saveInnovationIdeaRecord(serverRecord)
                    default:
                        break
                    }
                default:
                    let alert = UIAlertController(
                        title: "Could Not Save",
                        message: "The innovation idea couldn't be saved. Please try again later.",
                        preferredStyle: UIAlertController.Style.alert
                    )
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            guard let updatedRecord = savedRecords?.first else { return }
            
            NotificationCenter.default.post(name: recordDidChangeLocally,
                                            object: self,
                                            userInfo: ["recordChange" : RecordChange.updated(updatedRecord)])
        }
        
        self.publicCloudDatabase.add(modifyOperation)
    }
    // MARK: - UIPickerView DataSource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        return self.partners?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        let partner = self.partners?[row]
        
        return "\(partner?.firstName ?? "") \(partner?.lastName ?? "")"
    }
}
