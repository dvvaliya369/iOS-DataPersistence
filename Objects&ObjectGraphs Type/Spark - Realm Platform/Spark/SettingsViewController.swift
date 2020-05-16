import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var departmentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameTextField.text = UserDefaults.standard.string(forKey: "name")
        emailTextField.text = UserDefaults.standard.string(forKey: "email")
        departmentTextField.text = UserDefaults.standard.string(forKey: "department")
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(nameTextField.text, forKey: "name")
        UserDefaults.standard.set(emailTextField.text, forKey: "email")
        UserDefaults.standard.set(departmentTextField.text, forKey: "department")
        self.dismiss(animated: true, completion: nil)
    }
}
