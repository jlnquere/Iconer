//
//  IconSize.swift
//  Iconer
//
//  Created by Julien on 04/05/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import Foundation

struct IconSize:Hashable {
    var density:Int
    var pointSize:CGFloat
    
    var pixelSize:CGFloat {
        get {
            return CGFloat(density) * pointSize
        }
    }
    
    var fileName:String{
        get {
            var name = String(format: "%g", pointSize)
            if density != 1 {
                name = "\(name)@\(density)x"
            }
            return name
        }
    }
    
    
    init?(fromFileSizeName fileSizeName:String)  {
        
        let parts = fileSizeName.split(separator: "@")
        guard parts.count > 0 else {
            return nil
        }
        
        let pointSizeString = String(parts[0])
        
        guard let pointSize = Float(pointSizeString) else {
            return nil
        }
        self.pointSize = CGFloat(pointSize)
        
        
        if parts.count == 1 {
            density = 1
        } else {
            var densityString = parts[1]
            densityString.removeLast()
            guard let density = Int(densityString) else {
                return nil
            }
            self.density = density
        }
        
    }
    
    func isSameSize(_ size:CGFloat, allowDownscale downscale:Bool) -> Bool {
        if size == self.pixelSize {
            return true
        } else if downscale, size/2.0 == self.pixelSize {
            return true
        }
        return false
    }
    
    
}

extension IconSize: CustomStringConvertible {
    var description: String {
        return self.fileName
    }
}
