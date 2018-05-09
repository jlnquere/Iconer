//
//  IconerTests.swift
//  IconerTests
//
//  Created by Julien on 03/05/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import XCTest
@testable import Iconer
class IconerTests: XCTestCase {
    
    
    func testSizeParsingWithEmptyText() {
        let size = IconSize(fromFileSizeName: "")
        XCTAssertNil(size)
    }
    
    func testSizeParsingWithDumbText() {
        let size = IconSize(fromFileSizeName: "qsdqdqsdqs")
        XCTAssertNil(size)
    }
    
    func testSizeParsingWithoutScaleFactor() {
        let size = IconSize(fromFileSizeName: "70")
        XCTAssertNotNil(size)
        
        XCTAssertEqual(size!.pointSize, 70)
        XCTAssertEqual(size!.pixelSize, 70)
        XCTAssertEqual(size!.density, 1)
        XCTAssertEqual(size!.fileName, "70")
    }
    
    func testSizeParsingWithScaleFactor() {
        let size = IconSize(fromFileSizeName: "70@3x")
        XCTAssertNotNil(size)
        
        XCTAssertEqual(size!.pointSize, 70)
        XCTAssertEqual(size!.pixelSize, 210)
        XCTAssertEqual(size!.density, 3)
        XCTAssertEqual(size!.fileName, "70@3x")

    }
    
    func testSizeParsingWithFloatSize() {
        let size = IconSize(fromFileSizeName: "83.5@2x")
        XCTAssertNotNil(size)
        
        XCTAssertEqual(size!.pointSize, 83.5)
        XCTAssertEqual(size!.pixelSize, 167)
        XCTAssertEqual(size!.density, 2)
        XCTAssertEqual(size!.fileName, "83.5@2x")
    }

}
