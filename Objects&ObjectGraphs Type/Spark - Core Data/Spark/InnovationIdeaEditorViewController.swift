import UIKit
import CoreData

class InnovationIdeaEditorViewController:   UIViewController,
                                            UIPickerViewDataSource,
                                            UIPickerViewDelegate {

    var innovationIdea: InnovationIdea!
    var managedObjectContext: NSManagedObjectContext!

	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var partnerPicker: UIPickerView!
    
    var partners: [Employee]!
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		descriptionTextView.layer.borderWidth = CGFloat(0.5)
		descriptionTextView.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
		descriptionTextView.layer.cornerRadius = 5
		descriptionTextView.clipsToBounds = true
        
        self.partnerPicker.dataSource = self
        self.partnerPicker.delegate = self

        self.loadPartners()
        self.setUIValues()
	}

    func setUIValues() {
        guard let innovationIdea = self.innovationIdea else { return }

        self.titleTextField.text = innovationIdea.title
        self.descriptionTextView.text = innovationIdea.ideaDescription
        
        let selectedPartnerIndex = self.partners.index(of: innovationIdea.partner ?? Employee()) ?? 0
        
        self.partnerPicker.selectRow(selectedPartnerIndex, inComponent: 0, animated: false)
    }
    
    func loadPartners() {
        let employeeFetchRequest = NSFetchRequest<Employee>(entityName: Employee.entityName)
        
        let primarySortDescriptor = NSSortDescriptor(key: #keyPath(Employee.lastName),
                                                     ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: #keyPath(Employee.firstName),
                                                       ascending: true)
        
        employeeFetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]
        
        do {
            self.partners = try self.managedObjectContext.fetch(employeeFetchRequest)
        } catch {
            self.partners = []
            print("Something went wrong: \(error)")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.managedObjectContext.rollback()
        self.dismiss(animated: true, completion: nil)
    }
	
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let partner = self.partners[self.partnerPicker.selectedRow(inComponent: 0)]
        
        if self.innovationIdea == nil {
            self.innovationIdea = NSEntityDescription.insertNewObject(forEntityName: InnovationIdea.entityName,
                                                                      into: self.managedObjectContext) as! InnovationIdea
            self.innovationIdea.creationDate = Date()
        }

        self.innovationIdea.title = titleTextField.text ?? ""
        self.innovationIdea.ideaDescription = descriptionTextView.text
        self.innovationIdea.isDraft = true
        self.innovationIdea.partner = partner
        
        do {
            try self.managedObjectContext.save()
            self.dismiss(animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Trouble Saving",
                                          message: "Something went wrong when trying to save the Innovation Idea.  Please try again...",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: {(action: UIAlertAction) -> Void in
                                            self.managedObjectContext.rollback()
                                            self.innovationIdea = NSEntityDescription.insertNewObject(forEntityName: InnovationIdea.entityName, into: self.managedObjectContext) as? InnovationIdea
                                            
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIPickerView DataSource & Delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        return self.partners.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        let partner = self.partners[row]
        
        return "\(partner.firstName) \(partner.lastName)"
    }
}
