import UIKit
import RealmSwift

class InnovationIdeasViewController:    UIViewController,
                                        UITableViewDataSource,
                                        UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
    
    var defaultRealm: Realm!
    
    var innovationIdeas: Results<InnovationIdea>?
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
		super.viewDidLoad()
        
        self.authenticate()
        // loading innovation ideas and watching for data changes
        // requires an authenticated user, so these functions are called
        // within self.authenticate()
    }
    
    func authenticate() {
        if let user = SyncUser.current {
            // We have already logged in here!
            self.initializeDefaultRealm(forUser: user)
            self.loadInnovationIdeas()
            self.watchForDataChanges()
        } else {
            let credentials = SyncCredentials.nickname("Global User", isAdmin: true)
            
            SyncUser.logIn(with: credentials, server: Constants.AUTH_URL, onCompletion: { [weak self](user, err) in
                self!.initializeDefaultRealm(forUser: user!)
                self!.loadInnovationIdeas()
                self!.watchForDataChanges()
            })
        }
    }
    
    func initializeDefaultRealm(forUser user: SyncUser) {
        let config = user.configuration(realmURL: Constants.REALM_URL, fullSynchronization: true)
        self.defaultRealm = try! Realm(configuration: config)
    }
    
    func loadInnovationIdeas() {
        let date = Date(timeInterval: -1 * (60.0 * 60 * 24 * 30), since: Date())
        self.innovationIdeas = defaultRealm.objects(InnovationIdea.self).filter("creationDate > %@", date).sorted(byKeyPath: "title")
    }
    
    func watchForDataChanges() {
        self.notificationToken = innovationIdeas?.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.endUpdates()
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    // MARK: TableView Data Source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.innovationIdeas?.count ?? 0
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
		
        let innovationIdea = innovationIdeas?[indexPath.row]

		cell.textLabel?.text = innovationIdea?.title
        cell.detailTextLabel?.text = innovationIdea?.isDraft ?? true ? "Draft" : "Submitted"
		
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
            destinationVC.defaultRealm = self.defaultRealm
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow!
            let selectedInnovationIdea = innovationIdeas?[selectedIndexPath.row]
            
            destinationVC.innovationIdea = selectedInnovationIdea
        case "addIdea":
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! InnovationIdeaEditorViewController
            destinationVC.defaultRealm = self.defaultRealm
        default:
            break
        }
    }
}
