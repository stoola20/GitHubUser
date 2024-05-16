////
//  StringExtensionTests.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/15.
//

import XCTest
@testable import AccessAppExercise

final class StringExtensionTests: XCTestCase {

    func testGetNextLinkFromLinkHeader_ValidLink() {
        // Given
        let linkHeader = "<https://api.github.com/users?since=85&per_page=15>; rel=\"next\", <https://api.github.com/users{?since}>; rel=\"first\""
        
        // When
        let nextLink = linkHeader.getNextLinkFromLinkHeader()
        
        // Then
        XCTAssertEqual(nextLink, "https://api.github.com/users?since=85&per_page=15")
    }
    
    func testGetNextLinkFromLinkHeader_NoNextLink() {
        // Given
        let linkHeader = "<https://api.github.com/users{?since}>; rel=\"first\""
        
        // When
        let nextLink = linkHeader.getNextLinkFromLinkHeader()
        
        // Then
        XCTAssertNil(nextLink)
    }
    
    func testGetNextLinkFromLinkHeader_InvalidLink() {
        // Given
        let linkHeader = "Invalid Link Header"
        
        // When
        let nextLink = linkHeader.getNextLinkFromLinkHeader()
        
        // Then
        XCTAssertNil(nextLink)
    }
}
