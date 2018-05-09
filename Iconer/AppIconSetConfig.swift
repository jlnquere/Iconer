//
//  AppIconSetConfig.swift
//  Iconer
//
//  Created by Julien on 09/05/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import Foundation

enum AppIconSetConfig {
    case ios
    case macos
    
    static let allValues:[AppIconSetConfig] = [.ios, .macos]
    
    
    var expectedSizes:[IconSize] {
        return self.exepectedSizeNames.compactMap({IconSize.init(fromFileSizeName: $0)})
    }

    var contentJSONPath:URL? {
        return Bundle.main.url(forResource: self.contentJSONAssetName, withExtension: "json")
    }
    
    private var contentJSONAssetName:String {
        switch self {
        case .ios:
            return "appiconset_content-iOS"
        case .macos:
            return "appiconset_content-macOS"
        }
    }
    
    private var exepectedSizeNames:[String] {
        switch self {
        case .ios:
           return ["29@2x", "40", "57@2x", "76", "20", "40@2x", "60", "76@2x", "20@2x", "40@3x", "60@2x", "83.5@2x", "29", "50", "60@3x", "29@2x", "50@2x", "72", "29@3x", "57", "72@2x", "512@2x"]
        case .macos:
            return ["16", "32", "32@2x", "128", "256", "512", "512@2x"]
        }
    }
    
}

extension AppIconSetConfig:CustomStringConvertible {
    var description: String {
        get {
            switch self {
            case .ios:
                return "iOS"
            case .macos:
                return "macOS"
            }
        }
    }
}
