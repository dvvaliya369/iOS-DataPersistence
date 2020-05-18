//
//  ViewController.swift
//  Spark
//

import UIKit

class ViewController: UIViewController {
    
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
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(nameTextField.text, forKey: "name")
        UserDefaults.standard.set(emailTextField.text, forKey: "email")
        UserDefaults.standard.set(departmentTextField.text, forKey: "department")
        
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: "name")
    }
}

