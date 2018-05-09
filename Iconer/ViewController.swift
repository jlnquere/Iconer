//
//  ViewController.swift
//  Iconer
//
//  Created by Julien on 19/04/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    let imagesProcessor = ImageProcessor()
    @IBOutlet weak var dragView: DragDestinationView!
    override func viewDidLoad() {
        super.viewDidLoad()
        dragView.setup()
        dragView.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func showSavePanel() {
        let panel = NSOpenPanel()
        panel.message = "Select App Icon Set destination"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.begin { (response) in
            if response == .OK {
                guard let selectedURL = panel.urls.first else {
                    return
                }
                self.checkForIconAssetExistance(at: selectedURL)
            }
        }
    }
    
    private func checkForIconAssetExistance(at url:URL) {
        if self.imagesProcessor.doesAppIconSetExists(at: url) {
            let alert = NSAlert()
            
            alert.messageText = "AppIconSet already present in this folder. Would you like to overwrite it ?"
            alert.addButton(withTitle: "Overwrite")
            alert.addButton(withTitle: "Cancel")
            
            alert.beginSheetModal(for:  self.view.window!) { (response) in
                if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                    self.imagesProcessor.save(at: url, overwrite: true)
                }
            }
        } else {
            self.imagesProcessor.save(at: url)
        }
    }

    
    private func onMissingSizes(_ sizes:[IconSize]) {
        let alert = NSAlert()
        
        let missingSizesString = sizes.map({$0.fileName}).sorted().joined(separator: ",\n")
        
        alert.messageText = "Missing sizes: \n\(missingSizesString)"
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }

}

extension ViewController:DragDestinationDelegate {
    func dragDestinationView(_ view: DragDestinationView, didReceiveImages urls: [URL]) {
        self.imagesProcessor.prepareImages(at: urls) { (missingSizes) in
            if missingSizes.isEmpty {
                self.showSavePanel()
            } else {
                self.onMissingSizes(missingSizes)
            }
        }
    }
    
    
}

