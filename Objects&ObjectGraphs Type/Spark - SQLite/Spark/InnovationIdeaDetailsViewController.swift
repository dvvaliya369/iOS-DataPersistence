import UIKit

class InnovationIdeaDetailsViewController: UIViewController {
    
    var sqliteDatabaseConnection: OpaquePointer!

    var innovationIdea: InnovationIdea!
    
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var descriptionTextView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUIValues()
        self.watchForDataChanges()
    }
    
    func setUIValues() {
        self.titleLabel.text = self.innovationIdea.title
        self.descriptionTextView.text = self.innovationIdea.ideaDescription
    }
    
    func watchForDataChanges() {
        NotificationCenter.default.addObserver(forName: databaseDidSaveNotification,
                                               object: nil,
                                               queue: nil,
                                               using:
            {
                (notification: Notification) in
                if let updatedInnovationIdea = notification.userInfo?[UpdatedObjectKey] as? InnovationIdea {
                    self.innovationIdea = updatedInnovationIdea
                    self.setUIValues()
                }
        })
    }
    
    @IBAction func submitIdea(_ sender: UIBarButtonItem) {
        self.innovationIdea.dateSubmitted = Date()
        self.innovationIdea.isDraft = false
        self.innovationIdea.submittedBy = UserDefaults.standard.string(forKey: "name")
        self.innovationIdea.submitterEmailAddress = UserDefaults.standard.string(forKey: "email")
        self.innovationIdea.submitterDepartment = UserDefaults.standard.string(forKey: "department")
        
        SparkSQLite.updateInnovationIdea(connection: self.sqliteDatabaseConnection, innovationIdea: self.innovationIdea)
        
        NotificationCenter.default.post(name: databaseDidSaveNotification, object: self, userInfo: [UpdatedObjectKey: self.innovationIdea])
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Innovation Idea",
                                                message: "Are you sure you want to delete this idea?",
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (_) -> Void in
            
            SparkSQLite.deleteInnovationIdea(connection: self.sqliteDatabaseConnection, innovationIdea: self.innovationIdea)
            
            NotificationCenter.default.post(name: databaseDidSaveNotification, object: self)
            
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
        
        destinationVC.sqliteDatabaseConnection = self.sqliteDatabaseConnection
        destinationVC.innovationIdea = self.innovationIdea
	}
    
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: databaseDidSaveNotification,
                                                  object: nil)
    }
}
