//
//  ViewController.swift
//  Spark
//

import UIKit

struct Settings: Codable {
    var currentAppTheme: String
    let lightTheme: Theme
    let darkTheme: Theme
}

struct Theme: Codable {
    let fontName: String
    let primaryRGB: [CGFloat]
    let secondaryRGB: [CGFloat]
    let backgroundRGB: [CGFloat]
}

class ViewController: UIViewController {
    
    @IBOutlet weak var themeControl: UISegmentedControl!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var settings: Settings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let settingsURL = Bundle.main.url(forResource: "settings", withExtension: "plist")!
        
        let data = try! Data(contentsOf: settingsURL)
        
        let decoder = PropertyListDecoder()
        self.settings = try! decoder.decode(Settings.self, from: data)
        
        setTheme()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        let settingsURL = Bundle.main.url(forResource: "settings", withExtension: "plist")!
        
        let encoder = PropertyListEncoder()
        let encodedSettings = try! encoder.encode(self.settings)
        
        try! encodedSettings.write(to: settingsURL)
    }
    
    @IBAction func themeControlValueChanged(_ sender: Any) {
        self.settings?.currentAppTheme = self.themeControl.selectedSegmentIndex == 0 ? "Light" : "Dark"
        
        setTheme()
    }
    
    func setTheme() {
        guard let settings = self.settings else { return }
        
        if settings.currentAppTheme == "Light" {
            self.themeControl.selectedSegmentIndex = 0
            self.view.backgroundColor = UIColor.colorWithRedValue(redValue: settings.lightTheme.backgroundRGB[0],
                                                                  greenValue: settings.lightTheme.backgroundRGB[1],
                                                                  blueValue: settings.lightTheme.backgroundRGB[2],
                                                                  alpha: 1.0)
            
            self.themeLabel.textColor = UIColor.colorWithRedValue(redValue: settings.lightTheme.primaryRGB[0],
                                                                  greenValue: settings.lightTheme.primaryRGB[1],
                                                                  blueValue: settings.lightTheme.primaryRGB[2],
                                                                  alpha: 1.0)
            
            self.themeControl.tintColor = UIColor.colorWithRedValue(redValue: settings.lightTheme.secondaryRGB[0],
                                                                    greenValue: settings.lightTheme.secondaryRGB[1],
                                                                    blueValue: settings.lightTheme.secondaryRGB[2],
                                                                    alpha: 1.0)
            
            self.saveButton.tintColor = UIColor.colorWithRedValue(redValue: settings.lightTheme.secondaryRGB[0],
                                                                  greenValue: settings.lightTheme.secondaryRGB[1],
                                                                  blueValue: settings.lightTheme.secondaryRGB[2],
                                                                  alpha: 1.0)
        } else {
            self.themeControl.selectedSegmentIndex = 1
            self.view.backgroundColor = UIColor.colorWithRedValue(redValue: settings.darkTheme.backgroundRGB[0],
                                                                  greenValue: settings.darkTheme.backgroundRGB[1],
                                                                  blueValue: settings.darkTheme.backgroundRGB[2],
                                                                  alpha: 1.0)
            
            self.themeLabel.textColor = UIColor.colorWithRedValue(redValue: settings.darkTheme.primaryRGB[0],
                                                                  greenValue: settings.darkTheme.primaryRGB[1],
                                                                  blueValue: settings.darkTheme.primaryRGB[2],
                                                                  alpha: 1.0)
            
            self.themeControl.tintColor = UIColor.colorWithRedValue(redValue: settings.darkTheme.secondaryRGB[0],
                                                                    greenValue: settings.darkTheme.secondaryRGB[1],
                                                                    blueValue: settings.darkTheme.secondaryRGB[2],
                                                                    alpha: 1.0)
            
            self.saveButton.tintColor = UIColor.colorWithRedValue(redValue: settings.darkTheme.secondaryRGB[0],
                                                                  greenValue: settings.darkTheme.secondaryRGB[1],
                                                                  blueValue: settings.darkTheme.secondaryRGB[2],
                                                                  alpha: 1.0)
        }
    }
}

extension UIColor {
    static func colorWithRedValue(redValue: CGFloat, greenValue: CGFloat, blueValue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: redValue/255.0, green: greenValue/255.0, blue: blueValue/255.0, alpha: alpha)
    }
}
