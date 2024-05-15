////
//  String+Ext.swift
//  AccessAppExercise
//
//  Created by Jesse Chen on 2024/5/14.
//

import Foundation

extension String {
    func getNextLinkFromLinkHeader() -> String? {
        // Define the regular expression pattern
        let pattern = "<([^>]*)>; rel=\"next\""
        
        // Create a regular expression object
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }

        // Search for the string that matches the regular expression pattern
        let range = NSRange(self.startIndex..<self.endIndex, in: self)
        let matches = regex.matches(in: self, options: [], range: range)

        // Get the matching result
        if let match = matches.first {
            // Extract the matched string from the matching result
            let nsString = self as NSString
            let matchRange = match.range(at: 1)
            if matchRange.location != NSNotFound {
                return nsString.substring(with: matchRange)
            }
        }

        return nil
    }
}
