import UIKit
import CloudKit

class InnovationIdeasViewController:    UIViewController,
                                        UITableViewDataSource,
                                        UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
    
    var publicCloudDatabase: CKDatabase!
    
    var innovationIdeas = [InnovationIdea]()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.loadInnovationIdeas()
        self.watchForDataChanges()
	}
    
    func loadInnovationIdeas() {
        let date = Date(timeInterval: -1 * (60.0 * 60 * 24 * 30), since: Date())
        let predicate = NSPredicate(format: "creationDate >= %@", date as CVarArg)
        
        let innovationIdeasQuery = CKQuery(recordType: "InnovationIdea", predicate: predicate)
        
        let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        innovationIdeasQuery.sortDescriptors = [titleSortDescriptor]
        
        publicCloudDatabase.perform(innovationIdeasQuery,
                                    inZoneWith: nil)
        { (records, error) in
            guard let records = records else {return}
            self.innovationIdeas = records.map { InnovationIdea(record:$0) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccountStatusChange),
                                               name: Notification.Name.CKAccountChanged,
                                               object: nil)
    }
    
    @objc func handleAccountStatusChange() {
        CKContainer.default().accountStatus { (accountStatus, error) in
            switch accountStatus {
            case .couldNotDetermine, .noAccount, .restricted:
                let alert = UIAlertController(title: "iCloud Account Required",
                                              message: "Please sign in to your iCloud account or create one to make full use of this app.",
                                              preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            // Gracefully degrade the UI:  Disable 'Add' button, don't allow editing, etc.
            default: break // Gracefully upgrade the UI:  Enable add button, allow editing, etc.
            }
        }
    }
    
    @objc func handleLocalRecordChange(_ notification: Notification) {
        guard let recordChange = notification.userInfo?["recordChange"] as? RecordChange else { return }
        
        self.processChanges([recordChange])
    }
    
    @objc func handleRemoteRecordChange(_ notification: Notification) {
        // fetch changes
        // process changes
        // update UI
        CKContainer.default().fetchCloudKitRecordChanges() { changes in
            self.processChanges(changes)
        }
    }
    
    func processChanges(_ recordChanges: [RecordChange]) {
        for recordChange in recordChanges {
            switch recordChange {
            case .created(let createdCKRecord):
                let newInnovationIdea = InnovationIdea(record: createdCKRecord)
                self.innovationIdeas.append(newInnovationIdea)
            case .updated(let updatedCKRecord):
                // find existing hazard report in data source array
                let existingInnovationIdeaIndex = self.innovationIdeas.index { (report) -> Bool in
                    report.cloudKitRecord.recordID.recordName == updatedCKRecord.recordID.recordName
                }

                if let existingIndex = existingInnovationIdeaIndex {
                    let updatedInnovationIdea = InnovationIdea(record: updatedCKRecord)
                    
                        self.innovationIdeas[existingIndex] = updatedInnovationIdea
                }
                
            case .deleted(let deletedCKRecordID):
                let existingInnovationIdeaIndex = self.innovationIdeas.index { (report) -> Bool in
                    report.cloudKitRecord.recordID.recordName == deletedCKRecordID.recordName
                }
                
                if let existingIndex = existingInnovationIdeaIndex {
                    self.innovationIdeas.remove(at: existingIndex)
                }
            }
        }
        
        self.innovationIdeas.sort { (firstReport, secondReport) -> Bool in
            firstReport.title < secondReport.title
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK: TableView Data Source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.innovationIdeas.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
		
        let innovationIdea = self.innovationIdeas[indexPath.row]

		cell.textLabel?.text = innovationIdea.title
        cell.detailTextLabel?.text = innovationIdea.isDraft ? "Draft" : "Submitted"
		
		return cell
	}
	
	// MARK: TableView Delegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ideaDetails":
            let destinationVC = segue.destination as! InnovationIdeaDetailsViewController
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow!
            let selectedInnovationIdea = self.innovationIdeas[selectedIndexPath.row]
            
            destinationVC.innovationIdea = selectedInnovationIdea
        case "addIdea":
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! InnovationIdeaEditorViewController
            destinationVC.publicCloudDatabase = self.publicCloudDatabase
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: recordDidChangeLocally,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: recordDidChangeRemotely,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: Notification.Name.CKAccountChanged,
                                                  object: nil)
    }
}
