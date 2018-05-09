//
//  DragDestinationView.swift
//  Iconer
//
//  Created by Julien on 03/05/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import Cocoa

protocol DragDestinationDelegate: class {
    func dragDestinationView(_ view:DragDestinationView, didReceiveImages urls:[URL])
}

class DragDestinationView: NSView {

    weak var delegate:DragDestinationDelegate?
    @IBOutlet weak var messageLabel:NSTextField!
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
            messageLabel.isHidden = isReceivingDrag
        }
    }
    
    
    func setup() {
        let acceptableTypes = [NSPasteboard.PasteboardType(kUTTypeURL as String)]
        self.registerForDraggedTypes(acceptableTypes)
    }
    
    
    func imagesURL(for pasteBoard:NSPasteboard) -> [URL]? {
        
        let imageFilteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:NSImage.imageTypes]

        // If this is a bunch of png files, return it.
        if let imagesURL = pasteBoard.readObjects(forClasses: [NSURL.self], options: imageFilteringOptions) as? [URL],
            imagesURL.count > 0 {
            return imagesURL
        }
        
        if let folderURLs = pasteBoard.readObjects(forClasses: [NSURL.self], options: [:]) as? [URL],
            folderURLs.count == 1, let folderURL = folderURLs.first {
            let fileManager = FileManager()
            do {
              let content = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: [])
                
                return content.filter({self.isAnImageURL($0)})
            } catch {
                print("unable to list content of \(folderURL).\n\(error)")
                return nil
            }

        }
        return nil
    }
    
    
    private func isAnImageURL(_ url:URL) -> Bool {
        guard let uti = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            url.pathExtension as CFString,
            nil)?.takeRetainedValue() else {
                return false
        }
        return UTTypeConformsTo(uti, kUTTypeImage)
    }
    
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        guard let urls = imagesURL(for: pasteBoard), urls.count > 0 else {
            return false
        }
        
        return true
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = self.shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return shouldAllowDrag(sender)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        let pasteBoard = sender.draggingPasteboard()
        
        guard let urls = imagesURL(for: pasteBoard), urls.count > 0 else {
            return false
        }
        
        self.delegate?.dragDestinationView(self, didReceiveImages: urls)
        
        return true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            NSColor.selectedControlColor.setFill()
        } else {
            NSColor.controlHighlightColor.setFill()
        }
        dirtyRect.fill()
        super.draw(dirtyRect)
    }
}
