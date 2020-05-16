import UIKit
import Firebase

class InnovationIdeaEditorViewController:   UIViewController,
                                            UIPickerViewDataSource,
                                            UIPickerViewDelegate {

    var innovationIdea: InnovationIdea!
    var firestoreDB: Firestore!

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
        
        // partnerPicker is populated asynchronously, so setting this UI value
        // happens in the loadPartners() method
    }
    
    func loadPartners() {
        firestoreDB.collection("Employees").order(by: "lastName").order(by: "firstName").getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshot results: \(error!)")
                return
            }
            
            let employees = snapshot.documents.map({ (document) -> Employee in
                if let employee = Employee(documentID: document.documentID, firebaseDocument: document.data()) {
                    return employee
                } else {
                    // Don't use fatalError here in a real app. -- helpful for troubleshooting only
                    fatalError("Unable to initialize type \(Employee.self) with dictionary \(document.data())")
                }
            })
            
            self.partners = employees
            
            self.partnerPicker.reloadAllComponents()
            
            let selectedPartnerIndex = self.partners.firstIndex { (employee) -> Bool in
                return employee.documentID == self.innovationIdea?.partnerID ?? ""
                } ?? 0
            
            self.partnerPicker.selectRow(selectedPartnerIndex, inComponent: 0, animated: false)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
	
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let partner = self.partners[self.partnerPicker.selectedRow(inComponent: 0)]
        
        if var editedInnovationIdea = self.innovationIdea {
            
            editedInnovationIdea.title = titleTextField.text ?? ""
            editedInnovationIdea.ideaDescription = descriptionTextView.text
            editedInnovationIdea.isDraft = true
            editedInnovationIdea.partnerID = partner.documentID
            
            self.firestoreDB.collection("InnovationIdeas").document(editedInnovationIdea.documentID ?? "").setData(editedInnovationIdea.firestoreDocument) { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                } else {
                    print("Innovation Idea document successfully written!")
                }
            }
        } else {
            let newIdea = InnovationIdea(documentID: nil,
                                                title: titleTextField.text ?? "",
                                                ideaDescription: descriptionTextView.text,
                                                isDraft: true,
                                                dateSubmitted: nil,
                                                submittedBy: nil,
                                                submitterEmailAddress: nil,
                                                submitterDepartment: nil,
                                                partnerID: partner.documentID,
                                                creationDate: Date())
            
            
            self.firestoreDB.collection("InnovationIdeas").addDocument(data: newIdea.firestoreDocument) { (error) in
                if let err = error {
                    print("Error writing document: \(err)")
                } else {
                    print("Innovation Idea document successfully written!")
                }
            }
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
