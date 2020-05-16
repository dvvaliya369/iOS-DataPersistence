import UIKit
import AVFoundation

class DocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var proposalTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var document: Document?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        
        // Access the document
        document?.open(completionHandler: { (success) in
            if success {
                self.navigationController?.title = self.document?.fileURL.lastPathComponent
                self.titleTextField.text = self.document?.title
                self.proposalTextView.text = self.document?.proposal
                self.photoImageView.image = self.document?.photo
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    // MARK: - Choose Photo
    @IBAction func choosePhotoButtonTapped(_ sender: UIButton) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission()
        case .authorized: presentCamera()
        case .restricted, .denied: alertCameraAccessNeeded()
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video,
                                      completionHandler: {accessGranted in
                                        guard accessGranted == true else { return }
                                        self.presentCamera()
        })
    }
    
    func presentCamera() {
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        
        let alert = UIAlertController(
            title: "Need Camera Access",
            message: "Camera access is required for including pictures of hazards.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL,
                                      options: [:],
                                      completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let sparkPhoto = info[.originalImage] as! UIImage
        self.photoImageView.image = sparkPhoto
        
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true) {
            self.document?.title = self.titleTextField.text ?? ""
            self.document?.proposal = self.proposalTextView.text
            self.document?.photo = self.photoImageView.image
            
            self.document?.updateChangeCount(.done)
            self.document?.close(completionHandler: nil)
        }
    }
}
