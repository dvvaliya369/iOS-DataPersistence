import UIKit
import RealmSwift

class InnovationIdeaDetailsViewController: UIViewController {
    
    var defaultRealm: Realm!

    var innovationIdea: InnovationIdea!
    var notificationToken: NotificationToken?
    
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
        notificationToken = self.innovationIdea.observe { change in
            switch change {
            case .change(_):
                self.setUIValues()
            case .error(let error):
                print("An error occurred: \(error)")
            case .deleted:
                print("The object was deleted.")
            }
        }
    }
    
    @IBAction func submitIdea(_ sender: UIBarButtonItem) {
        try! self.defaultRealm.write {
            self.innovationIdea.dateSubmitted = Date()
            self.innovationIdea.isDraft = false
            self.innovationIdea.submittedBy = UserDefaults.standard.string(forKey: "name")
            self.innovationIdea.submitterEmailAddress = UserDefaults.standard.string(forKey: "email")
            self.innovationIdea.submitterDepartment = UserDefaults.standard.string(forKey: "department")
        }
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Innovation Idea",
                                                message: "Are you sure you want to delete this Innovation Idea?",
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (_) -> Void in
            
            try! self.defaultRealm.write {
                self.defaultRealm.delete(self.innovationIdea)
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
        
        destinationVC.defaultRealm = self.defaultRealm
        destinationVC.innovationIdea = self.innovationIdea
    }
}
