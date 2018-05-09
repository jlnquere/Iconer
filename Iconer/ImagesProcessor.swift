//
//  ImagesProcessor.swift
//  Iconer
//
//  Created by Julien on 03/05/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import Foundation
import AppKit

class ImageProcessor {
    
    private let appIconSetName = "AppIcon.appiconset"
    private let appIconBaseFileName = "appicon-"
    
    private let fileManager = FileManager()
    
    private var inputSizes = [URL:CGFloat]()
    private var inputImages = [IconSize:URL]()
    
     let config:AppIconSetConfig
    
    
    init(type config:AppIconSetConfig) {
        self.config = config
    }
    
    
    
    func doesAppIconSetExists(at url:URL) -> Bool {
        let appIconSetURL = url.appendingPathComponent(appIconSetName)
        return fileManager.fileExists(atPath: appIconSetURL.path)
    }
    
    
    func save(at url:URL, overwrite:Bool = false) {
        var appIconSet:URL?
        do {
            appIconSet = try self.createAppIconSetDirectory()
        } catch {
            print("Error while getting appIconSet folder \(error)")
        }

        guard let appIconSetFolder = appIconSet else {
            return
        }

        do {
            try saveContentJSON(at: appIconSetFolder)
        } catch {
            print("Error while saving: \(error)")
        }
        
        do {
            try inputImages.forEach { (size, url) in
                try processImage(at: url, for: size, to: appIconSetFolder)
            }
        } catch {
            print("Error while processing image.\(error)")
        }
        
        do {
            let appIconSetURL = url.appendingPathComponent(appIconSetName)
            
            if self.doesAppIconSetExists(at: url), overwrite {
                try fileManager.removeItem(at: appIconSetURL)
            }
            
            try fileManager.moveItem(at: appIconSetFolder, to: appIconSetURL)

        } catch {
            print("Failed to move items to destination folder.\(error)")
        }
    }
    
    private func processImage(at source:URL, for size:IconSize, to destination:URL) throws {
        
        let fileDestination = destination.appendingPathComponent("\(appIconBaseFileName)\(size.fileName).png")
        let originalImageSize = try self.sideSize(forImageAt: source)
        if size.isSameSize(originalImageSize, allowDownscale: false) {
            try fileManager.copyItem(at: source, to: fileDestination)
        } else {
            let resizedImage = try self.resizeImage(at:source, to: NSSize(width: size.pixelSize, height: size.pixelSize))
            try resizedImage.savePNG(to: fileDestination)
        }
        

    }
    
    private func resizeImage(at url:URL, to:NSSize) throws -> NSImage {
        
        guard let image = NSImage(contentsOf: url) else {
            throw "Failure to create NSImage from URL"
        }
        
        guard image.isValid else {
            throw "Source image invalid"
        }
        
        guard let resizedImage = image.resize(withSize: to) else {
            throw "Failed to resize image"
        }
        return resizedImage
    }
    
    private func createAppIconSetDirectory() throws -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw("Failed to create temp working directory.\n\(error)")
        }
        let appIconSet = tempURL.appendingPathComponent(appIconSetName)
        do {
            try fileManager.createDirectory(at: appIconSet, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw("Failed to create app icon set directory.\n\(error)")
        }
        return appIconSet
    }
    
    private func saveContentJSON(at url:URL) throws {
        let contentFile = url.appendingPathComponent("Contents.json").path
        
        guard let contentJSONPath = config.contentJSONPath else {
            throw "Unable to get appiconset_content path"
        }
        
        guard let contentJSONData = try? Data(contentsOf: contentJSONPath) else {
            throw "Unable to get appiconset_content data"
            
        }
        guard fileManager.createFile(atPath: contentFile, contents: contentJSONData, attributes: nil) else {
            throw "Unable to get create Contents.json"
        }
    }
    
    func prepareImages(at urls:[URL], completion:((_ missing:[IconSize])->Void)?) {
        inputSizes.removeAll()
        inputImages.removeAll()
        
        urls.forEach({
            if let sideSize = try? self.sideSize(forImageAt: $0) {
                inputSizes[$0] = CGFloat(sideSize)
            }
        })
    
    
        var missingSizes = [IconSize]()
        
        config.expectedSizes.forEach { (size) in
            if let url = self.searchImageCandidate(for: size) {
                inputImages[size] = url
            } else {
                missingSizes.append(size)
            }
        }
        inputSizes.removeAll()
        completion?(missingSizes)
    }
    
    private func sideSize(forImageAt url:URL) throws -> CGFloat {
        guard let image = NSImage(contentsOf: url) else {
            throw "Failure to create NSImage from URL"
        }
        
        let width = image.representations.map({$0.pixelsWide}).max()
        let height = image.representations.map({$0.pixelsHigh}).max()
        
        guard width == height, let floatWidth = width.map({CGFloat($0)}) else {
            throw "Image should be a square"
        }
        
        return floatWidth
    }
    

    private func searchImageCandidate(for size:IconSize) -> URL? {
        
        var result:URL?
        
        result =  self.inputSizes.first { (arg) -> Bool in
            let (_, elementSize) = arg
            return size.isSameSize(elementSize, allowDownscale: false)
            }?.key
        
        if result == nil {
            result =  self.inputSizes.first { (arg) -> Bool in
                let (_, elementSize) = arg
                return size.isSameSize(elementSize, allowDownscale: true)
                }?.key
        }
        return result
    }
}
