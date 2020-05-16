import UIKit

enum SparkError: Error {
    case PlistReadFailed
}

class Document: UIDocument {
    static let sparkFileExtension = "sparkFile"
    
    var title: String = ""
    
    var proposal: String = ""
    
    var photo: UIImage?
    
    // File names in Document "Package"
    fileprivate let metadataFileName = "Metadata.plist"
    fileprivate let proposalFileName = "Proposal.txt"
    fileprivate let photoFileName = "Photo.jpg"
    
    // Metadata key for accessing the innovation idea's title
    fileprivate let titleKey = "title"
    
    // Overall, top-level FileWrapper to package up a "Document"
    var documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
    
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        
        let metadataPlist = [titleKey: self.title]
        let metadataData = try PropertyListSerialization.data(fromPropertyList: metadataPlist, format: .binary, options: 0)
        let metadataWrapper = FileWrapper(regularFileWithContents: metadataData)
        metadataWrapper.preferredFilename = metadataFileName
        self.documentWrapper.addFileWrapper(metadataWrapper)
        
        if let proposalData = self.proposal.data(using: .utf8) {
            let proposalWrapper = FileWrapper(regularFileWithContents: proposalData)
            proposalWrapper.preferredFilename = proposalFileName
            self.documentWrapper.addFileWrapper(proposalWrapper)
        }
        
        if let imageData = self.photo?.jpegData(compressionQuality: 0.9) {
            let imageWrapper = FileWrapper(regularFileWithContents: imageData)
            imageWrapper.preferredFilename = photoFileName
            self.documentWrapper.addFileWrapper(imageWrapper)
        }
        
        return self.documentWrapper
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        
        guard let topLevelFileWrapper = (contents as? FileWrapper)?.fileWrappers else {
            fatalError("Oops...expecting File Wrapper but instead the contents were \(type(of: contents)).")
        }
        
        if let metadataWrapper = topLevelFileWrapper[metadataFileName] {
            guard let metadataData = metadataWrapper.regularFileContents else { return }
            guard let plist = try PropertyListSerialization.propertyList(from: metadataData, options: .mutableContainersAndLeaves, format: nil) as? [String: AnyObject] else {
                throw SparkError.PlistReadFailed
            }
            
            self.title = plist[titleKey] as? String ?? ""
        }
        
        if let proposalWrapper = topLevelFileWrapper[proposalFileName] {
            guard let proposalData = proposalWrapper.regularFileContents else { return }
            self.proposal = String(data: proposalData, encoding: .utf8) ?? ""
        }
        
        if let photoWrapper = topLevelFileWrapper[photoFileName] {
            guard let photoData = photoWrapper.regularFileContents else { return }
            self.photo = UIImage(data: photoData) // You know this is a UIImage because you know what you're storing under the file named "Photo.jpg" within your document package
        }
    }
}

