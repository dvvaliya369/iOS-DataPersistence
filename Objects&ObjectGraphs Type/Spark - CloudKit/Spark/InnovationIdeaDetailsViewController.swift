import UIKit
import CloudKit

class InnovationIdeaDetailsViewController: UIViewController {
    
    var publicCloudDatabase: CKDatabase!

    var innovationIdea: InnovationIdea!

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionTextView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUIValues()
        self.watchForDataChanges()
    }
	
    func watchForDataChanges() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleLocalRecordChange),
                                               name: recordDidChangeLocally,
                                               object: nil)
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRemoteRecordChange),
                                               name: recordDidChangeRemotely,
                                               object: nil)
    }
    
    @objc func handleLocalRecordChange(_ notification: Notification) {
        guard let recordChange = notification.userInfo?["recordChange"] as? RecordChange else { return }
        
        self.processRecordChanges([recordChange])
    }
    
    @objc func handleRemoteRecordChange(_ notification: Notification) {
        CKContainer.default().fetchCloudKitRecordChanges() { changes in
            self.processRecordChanges(changes)
        }
    }
    
    func processRecordChanges(_ recordChanges: [RecordChange]) {
        for recordChange in recordChanges {
            switch recordChange {
            case .updated(let record):
                guard record.recordID == self.innovationIdea.cloudKitRecord.recordID else { continue }
                
                self.innovationIdea = InnovationIdea(record: record)
            default: continue
            }
        }
        
        DispatchQueue.main.async {
            self.setUIValues()
        }
    }
    
    func setUIValues() {
        self.titleLabel.text = self.innovationIdea.title
        self.descriptionTextView.text = self.innovationIdea.ideaDescription
    }
    
    @IBAction func submitIdea(_ sender: UIBarButtonItem) {
        self.innovationIdea.dateSubmitted = Date()
        self.innovationIdea.isDraft = false
        self.innovationIdea.submittedBy = UserDefaults.standard.string(forKey: "name")
        self.innovationIdea.submitterEmailAddress = UserDefaults.standard.string(forKey: "email")
        self.innovationIdea.submitterDepartment = UserDefaults.standard.string(forKey: "department")
        
            let modifyOperation = CKModifyRecordsOperation(recordsToSave:   [self.innovationIdea.cloudKitRecord],
                                                                            recordIDsToDelete: nil)
        
        modifyOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            guard let updatedRecord = savedRecords?.first else { return }
            
            NotificationCenter.default.post(name: recordDidChangeLocally, object: self, userInfo: ["recordChange" : RecordChange.updated(updatedRecord)])
        }
        
        self.publicCloudDatabase.add(modifyOperation)
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Innovation Idea",
                                                message: "Are you sure you want to delete this Innovation Idea?",
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (_) -> Void in
            
            let deleteOperation = CKModifyRecordsOperation(recordsToSave: nil,
                                                           recordIDsToDelete: [self.innovationIdea.cloudKitRecord.recordID])
            
            deleteOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                guard let deletedRecordID = deletedRecordIDs?.first else { return }
                
                NotificationCenter.default.post(name: recordDidChangeLocally, object: self, userInfo: ["recordChange" : RecordChange.deleted(deletedRecordID)])
            }
            
            self.publicCloudDatabase.add(deleteOperation)
            
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let destinationVC = navigationController.viewControllers[0] as! InnovationIdeaEditorViewController
        
        destinationVC.publicCloudDatabase = self.publicCloudDatabase
        destinationVC.innovationIdea = self.innovationIdea
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: recordDidChangeLocally,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: recordDidChangeRemotely,
                                                  object: nil)
    }
}
