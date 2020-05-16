import UIKit
import SQLite3

class InnovationIdeasViewController: UIViewController,
									UITableViewDataSource,
									UITableViewDelegate {

	@IBOutlet weak var tableView: UITableView!
	
    var sqliteDatabaseConnection: OpaquePointer!

    var innovationIdeas = [InnovationIdea]()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.loadInnovationIdeas()
        self.watchForDataChanges()
    }
    
    func loadInnovationIdeas() {
        self.innovationIdeas = SparkSQLite.getAllInnovationIdeas(connection: self.sqliteDatabaseConnection)
    }
    
    func watchForDataChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDatabaseDidSave), name: databaseDidSaveNotification, object: nil)
    }
    
    @objc func onDatabaseDidSave(notification: Notification) {
        self.innovationIdeas = SparkSQLite.getAllInnovationIdeas(connection: self.sqliteDatabaseConnection)
        self.tableView.reloadData()
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
            let selectedIdea = self.innovationIdeas[selectedIndexPath.row]
            
            destinationVC.sqliteDatabaseConnection = self.sqliteDatabaseConnection
            destinationVC.innovationIdea = selectedIdea
        case "addIdea":
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! InnovationIdeaEditorViewController
            destinationVC.sqliteDatabaseConnection = self.sqliteDatabaseConnection
        default:
            break
        }
	}
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: databaseDidSaveNotification,
                                                  object: nil)
    }
}
