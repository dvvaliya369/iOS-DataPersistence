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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: NSUbiquitousKeyValueStore.default)
        
        NSUbiquitousKeyValueStore.default.synchronize()
        
        refreshUI()
    }
    
    @objc func onUbiquitousKeyValueStoreDidChangeExternally(notification:Notification) {
        let changeReason = notification.userInfo![NSUbiquitousKeyValueStoreChangeReasonKey] as! Int
        let changedKeys = notification.userInfo![NSUbiquitousKeyValueStoreChangedKeysKey] as! [String]
        
        switch changeReason {
        case NSUbiquitousKeyValueStoreInitialSyncChange,
             NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreAccountChange:
            refreshUI()
            
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            // Reduce amount of data stored in iCloud Key-Value Store
            break
            
        default: break
        }
    }
    
    func refreshUI() {
        nameTextField.text = NSUbiquitousKeyValueStore.default.string(forKey: "name")
        emailTextField.text = NSUbiquitousKeyValueStore.default.string(forKey: "email")
        departmentTextField.text = NSUbiquitousKeyValueStore.default.string(forKey: "department")
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        NSUbiquitousKeyValueStore.default.set(nameTextField.text, forKey: "name")
        NSUbiquitousKeyValueStore.default.set(emailTextField.text, forKey: "email")
        NSUbiquitousKeyValueStore.default.set(departmentTextField.text, forKey: "department")
        
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func clear() {
        NSUbiquitousKeyValueStore.default.removeObject(forKey: "name")
    }
}

