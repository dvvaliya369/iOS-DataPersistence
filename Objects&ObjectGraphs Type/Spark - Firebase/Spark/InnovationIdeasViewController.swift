import UIKit
import Firebase

class InnovationIdeasViewController:    UIViewController,
                                        UITableViewDataSource,
                                        UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
    
    var firestoreDB: Firestore!

    var innovationIdeas = [InnovationIdea]()
    var innovationIdeaDocumentSnapshots = [DocumentSnapshot]()
    
    override func viewDidLoad() {
		super.viewDidLoad()
        
        let date = Date(timeInterval: -1 * (60.0 * 60 * 24 * 30), since: Date())
        let firebaseTimestamp = Timestamp(date: date)
        
        firestoreDB.collection("InnovationIdeas")
            .whereField("creationDate", isGreaterThanOrEqualTo: firebaseTimestamp)
            .addSnapshotListener({ [unowned self] (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let innovationIdeas = snapshot.documents.map({ (document) -> InnovationIdea in
                if let innovationIdea = InnovationIdea(documentID: document.documentID, firebaseDocument: document.data()) {
                    return innovationIdea
                } else {
                    // Don't use fatalError here in a real app. -- helpful for troubleshooting only
                    fatalError("Unable to initialize type \(InnovationIdea.self) with dictionary \(document.data())")
                }
            })
            
            self.innovationIdeas = innovationIdeas
            self.innovationIdeaDocumentSnapshots = snapshot.documents
            
            self.tableView.reloadData()
        })
        
    }
    
    // MARK: TableView Data Source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.innovationIdeas.count
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
		
        let innovationIdea = innovationIdeas[indexPath.row]

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
            let selectedInnovationIdea = innovationIdeas[selectedIndexPath.row]
            
            destinationVC.innovationIdea = selectedInnovationIdea
            destinationVC.firestoreDB = self.firestoreDB
        case "addIdea":
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! InnovationIdeaEditorViewController
            destinationVC.firestoreDB = self.firestoreDB
        default:
            break
        }
    }
}
