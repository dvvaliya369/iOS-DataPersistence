import UIKit
import SQLite3

class InnovationIdeaEditorViewController:   UIViewController,
                                            UIPickerViewDataSource,
                                            UIPickerViewDelegate {

    var sqliteDatabaseConnection: OpaquePointer!

    var innovationIdea: InnovationIdea?
    
	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var partnerPicker: UIPickerView!
    
    var partners = [Employee]()
    
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
        
        let selectedPartnerIndex = self.partners.firstIndex { (employee) -> Bool in
            employee.employeeID == innovationIdea.partnerEmployeeID
        }
        
        if let index = selectedPartnerIndex {
            self.partnerPicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            self.partnerPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    func loadPartners() {
        self.partners = SparkSQLite.getAllEmployees(connection: self.sqliteDatabaseConnection)
    }
    
	@IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let partner = self.partners[self.partnerPicker.selectedRow(inComponent: 0)]
        
        let defaultSubmittedDate = Date.init(timeIntervalSince1970: 0)
        
        if var editedInnovationIdea = self.innovationIdea {
            editedInnovationIdea.title = titleTextField.text ?? ""
            editedInnovationIdea.ideaDescription = descriptionTextView.text
            editedInnovationIdea.partnerEmployeeID = partner.employeeID
            
            SparkSQLite.updateInnovationIdea(connection: self.sqliteDatabaseConnection, innovationIdea: editedInnovationIdea)
            
            NotificationCenter.default.post(name: databaseDidSaveNotification, object: self, userInfo: [UpdatedObjectKey: editedInnovationIdea])
        } else {
            var newIdea = InnovationIdea(innovationIdeaID: nil,
                                         title: titleTextField.text ?? "",
                                         ideaDescription: descriptionTextView.text,
                                         isDraft: true,
                                         dateSubmitted: defaultSubmittedDate,
                                         submittedBy: nil,
                                         submitterEmailAddress: nil,
                                         submitterDepartment: nil,
                                         partnerEmployeeID: partner.employeeID,
                                         creationDate: Date())
            
            SparkSQLite.insertInnovationIdea(connection: self.sqliteDatabaseConnection, innovationIdea: newIdea)
            newIdea.innovationIdeaID = Int(sqlite3_last_insert_rowid(self.sqliteDatabaseConnection))
            
            NotificationCenter.default.post(name: databaseDidSaveNotification, object: self, userInfo: [UpdatedObjectKey: newIdea])
        }
        
        
		self.dismiss(animated: true, completion: nil)
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
