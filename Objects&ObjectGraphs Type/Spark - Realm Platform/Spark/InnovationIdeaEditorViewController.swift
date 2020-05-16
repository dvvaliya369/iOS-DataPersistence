import UIKit
import RealmSwift

class InnovationIdeaEditorViewController:   UIViewController,
                                            UIPickerViewDataSource,
                                            UIPickerViewDelegate {

    var innovationIdea: InnovationIdea?
    var defaultRealm: Realm!

	@IBOutlet weak var descriptionTextView: UITextView!
	@IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var partnerPicker: UIPickerView!
    
    var partners: Results<Employee>!
    
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
        self.partners = defaultRealm.objects(Employee.self).sorted(byKeyPath: "lastName").sorted(byKeyPath: "firstName")
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
	
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let partner = self.partners[self.partnerPicker.selectedRow(inComponent: 0)]
        
        if var editedInnovationIdea = self.innovationIdea {
            do {
                try self.defaultRealm.write {
                    editedInnovationIdea.title = titleTextField.text ?? ""
                    editedInnovationIdea.ideaDescription = descriptionTextView.text
                    editedInnovationIdea.isDraft = true
                    editedInnovationIdea.partner = partner
                }
                
                self.dismiss(animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "Trouble Saving",
                                              message: "Something went wrong when trying to save the Innovation Idea.  Please try again...",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let newIdea = InnovationIdea(title: titleTextField.text ?? "",
                                         ideaDescription: descriptionTextView.text,
                                         isDraft: true,
                                         dateSubmitted: nil,
                                         submittedBy: nil,
                                         submitterEmailAddress: nil,
                                         submitterDepartment: nil,
                                         partner: partner,
                                         creationDate: Date())
            
            do {
                try self.defaultRealm.write {
                    self.defaultRealm.add(newIdea)
                }
                
                self.dismiss(animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "Trouble Saving",
                                              message: "Something went wrong when trying to save the Innovation Idea.  Please try again...",
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil)
                
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
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
