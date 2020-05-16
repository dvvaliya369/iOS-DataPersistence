import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func newDocumentURL() -> URL {
        let cacheDirectoryURL = try! FileManager
                                    .default
                                    .url(for: .cachesDirectory,
                                         in: .userDomainMask,
                                         appropriateFor: nil,
                                         create: true)
        
        let documentNumberKey = "documentNumber"
        let documentNumber = UserDefaults.standard.integer(forKey: documentNumberKey)
        let newDocumentName = "Untitled \(documentNumber)"
        let newDocumentURL = cacheDirectoryURL.appendingPathComponent(newDocumentName).appendingPathExtension(Document.sparkFileExtension)
        
        let nextDocumentNumber = UserDefaults.standard.integer(forKey: documentNumberKey) + 1
        UserDefaults.standard.set(nextDocumentNumber, forKey: documentNumberKey)
        
        return newDocumentURL
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL = self.newDocumentURL()
        let newSparkDocument = Document(fileURL: newDocumentURL)
        
        newSparkDocument.save(to: newDocumentURL, for: .forCreating) { saveSuccess in
            
            guard saveSuccess else {
                importHandler(nil, .none)
                return
            }
            
            importHandler(newDocumentURL, .move)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyBoard.instantiateViewController(withIdentifier: "SparkDocumentEditorNavigationController") as! UINavigationController
        
        let documentViewController = navigationController.viewControllers.first as! DocumentViewController
        documentViewController.document = Document(fileURL: documentURL)
        
        present(navigationController, animated: true, completion: nil)
    }
}

