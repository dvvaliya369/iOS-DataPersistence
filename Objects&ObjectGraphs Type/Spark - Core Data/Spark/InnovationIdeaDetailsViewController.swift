import UIKit
import CoreData

class InnovationIdeaDetailsViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!

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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: nil,
                                               queue: nil,
                                               using:
            {
                (notification: Notification) in
                if let updatedInnovationIdeas = notification.userInfo?[NSUpdatedObjectsKey] as? Set<InnovationIdea> {
                    self.innovationIdea = updatedInnovationIdeas.first
                    if self.innovationIdea != nil {
                        self.setUIValues()
                    }
                }
        })
    }
    
    @IBAction func submitIdea(_ sender: UIBarButtonItem) {
        self.innovationIdea.dateSubmitted = Date()
        self.innovationIdea.isDraft = false
        self.innovationIdea.submittedBy = UserDefaults.standard.string(forKey: "name")
        self.innovationIdea.submitterEmailAddress = UserDefaults.standard.string(forKey: "email")
        self.innovationIdea.submitterDepartment = UserDefaults.standard.string(forKey: "department")
        
        try? self.managedObjectContext.save()
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Innovation Idea",
                                                message: "Are you sure you want to delete this Innovation Idea?",
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (_) -> Void in
            
            self.managedObjectContext.delete(self.innovationIdea)
            
            do {
                try self.managedObjectContext.save()
            } catch {
                self.managedObjectContext.rollback()
                print("Something went wrong: \(error)")
            }
            
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
        
        destinationVC.managedObjectContext = self.managedObjectContext
        destinationVC.innovationIdea = self.innovationIdea
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.NSManagedObjectContextDidSave,
                                                  object: nil)
    }
}
