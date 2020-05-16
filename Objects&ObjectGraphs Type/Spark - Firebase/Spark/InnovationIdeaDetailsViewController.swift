import UIKit
import Firebase

class InnovationIdeaDetailsViewController: UIViewController {
    
    var firestoreDB: Firestore!

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
        firestoreDB.collection("InnovationIdeas").document(self.innovationIdea.documentID ?? "").addSnapshotListener { (documentSnapshot, error) in
            guard let innovationIdeaDocument = documentSnapshot, innovationIdeaDocument.exists else {
                print("Document does not exist")
                return
            }
            
            self.innovationIdea = InnovationIdea(documentID: innovationIdeaDocument.documentID, firebaseDocument: innovationIdeaDocument.data()!)
            
            self.setUIValues()
        }
    }
    
    @IBAction func submitIdea(_ sender: UIBarButtonItem) {
        self.innovationIdea.dateSubmitted = Date()
        self.innovationIdea.isDraft = false
        self.innovationIdea.submittedBy = UserDefaults.standard.string(forKey: "name")
        self.innovationIdea.submitterEmailAddress = UserDefaults.standard.string(forKey: "email")
        self.innovationIdea.submitterDepartment = UserDefaults.standard.string(forKey: "department")
        
        self.firestoreDB.collection("InnovationIdeas").document(self.innovationIdea.documentID ?? "").setData(self.innovationIdea.firestoreDocument) { (error) in
            if let err = error {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete Innovation Idea",
                                                message: "Are you sure you want to delete this Innovation Idea?",
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            (_) -> Void in
            
            self.firestoreDB.collection("InnovationIdeas").document(self.innovationIdea.documentID ?? "").delete(completion: { (error) in
                if let err = error {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            })
            
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
        
        destinationVC.innovationIdea = self.innovationIdea
        destinationVC.firestoreDB = self.firestoreDB
    }
}
