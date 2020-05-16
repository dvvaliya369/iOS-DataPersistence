import UIKit
import CoreData

class InnovationIdeasViewController:    UIViewController,
                                        UITableViewDataSource,
                                        UITableViewDelegate,
                                        NSFetchedResultsControllerDelegate {

	@IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<InnovationIdea>!
    
    var innovationIdeas = [InnovationIdea]()
    
    override func viewDidLoad() {
		super.viewDidLoad()
        
        self.loadInnovationIdeas()
        
        // Watching for data changes happens through NSFetchedResultsControllerDelegate method implementations
	}
    
    func loadInnovationIdeas() {
        let innovationIdeasFetchRequest = NSFetchRequest<InnovationIdea>(entityName: InnovationIdea.entityName)
        
        let date = Date(timeInterval: -1 * (60.0 * 60 * 24 * 30), since: Date())
        let predicate = NSPredicate(format: "creationDate >= %@", date as CVarArg)
        innovationIdeasFetchRequest.predicate = predicate
        
        let titleSortDescriptor = NSSortDescriptor(key: #keyPath(InnovationIdea.title), ascending: true)
        innovationIdeasFetchRequest.sortDescriptors = [titleSortDescriptor]
        
        self.fetchedResultsController = NSFetchedResultsController<InnovationIdea>(fetchRequest: innovationIdeasFetchRequest,
                                                                                   managedObjectContext: self.managedObjectContext,
                                                                                   sectionNameKeyPath: nil,
                                                                                   cacheName: nil)
        
        self.fetchedResultsController.delegate = self
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let alertController = UIAlertController(title: "Loading Innovation Ideas Failed",
                                                    message: "There was a problem loading the list of Innovation Ideas. Please try again.",
                                                    preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: TableView Data Source methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = self.fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
    }
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        
        return 0
    }
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
		
        let innovationIdea = self.fetchedResultsController.object(at: indexPath)

		cell.textLabel?.text = innovationIdea.title
        cell.detailTextLabel?.text = innovationIdea.isDraft ? "Draft" : "Submitted"
		
		return cell
	}
	
	// MARK: TableView Delegate methods
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
    // MARK: NSFetchedResultsController Delegate methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath {
                let cell = self.tableView.cellForRow(at: updateIndexPath)
                let updatedInnovationIdea = self.fetchedResultsController.object(at: updateIndexPath)
                
                cell?.textLabel?.text = updatedInnovationIdea.title
                cell?.detailTextLabel?.text = updatedInnovationIdea.isDraft ? "Draft" : "Submitted"
            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
            
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = NSIndexSet(index: sectionIndex) as IndexSet
        
        switch type {
        case .insert:
            self.tableView.insertSections(sectionIndexSet, with: .fade)
        case .delete:
            self.tableView.deleteSections(sectionIndexSet, with: .fade)
        default:
            break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ideaDetails":
            let destinationVC = segue.destination as! InnovationIdeaDetailsViewController
            destinationVC.managedObjectContext = self.managedObjectContext
            
            let selectedIndexPath = self.tableView.indexPathForSelectedRow!
            let selectedInnovationIdea = self.fetchedResultsController.object(at: selectedIndexPath)
            
            destinationVC.innovationIdea = selectedInnovationIdea
        case "addIdea":
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! InnovationIdeaEditorViewController
            destinationVC.managedObjectContext = self.managedObjectContext
        default:
            break
        }
    }
}
