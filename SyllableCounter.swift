//
//  SyllableCounter.swift
//
//  Created by Warren Freitag on 2/14/16.
//  Copyright © 2016 Warren Freitag. All rights reserved.
//  Licensed under the Apache 2.0 License.
//
//  Adapted from a Java implementation created by Hugo "m09" Mougard.
//  https://github.com/m09/syllable-counter
//

import UIKit

class SyllableCounter {
    
    // MARK: - Shared instance
    
    static let sharedInstance = SyllableCounter()
    
    // MARK: - Private properties
    
    private var exceptions: [String: Int]!
    
    private var addSyl: [NSRegularExpression!]!
    private var subSyl: [NSRegularExpression!]!
    
    private let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
    
    // MARK: - Error enum
    
    private enum SyllableCounterError: ErrorType {
        case BadRegex(String)
        case MissingExceptionsDataAsset
        case BadExceptionsData(String)
    }
    
    // MARK: - Constructors
    
    init() {
        do {
            try populateAddSyl()
            try populateSubSyl()
            try populateExceptions()
        }
        catch SyllableCounterError.BadRegex(let pattern) {
            print("Bad Regex pattern: \(pattern)")
        }
        catch SyllableCounterError.MissingExceptionsDataAsset {
            print("Missing exceptions dataset.")
        }
        catch SyllableCounterError.BadExceptionsData(let info) {
            print("Problem parsing exceptions dataset: \(info)")
        }
        catch {
            print("An unexpected error occured while initializing the syllable counter.")
        }
    }
    
    // MARK: - Setup
    
    private func populateAddSyl() throws {
        try addSyl = buildRegexesForPatterns([
            "ia", "riet", "dien", "iu", "io", "ii",
            "[aeiouy]bl$", "mbl$", "tl$", "sl$", "[aeiou]{3}",
            "^mc", "ism$", "(.)(?!\\1)([aeiouy])\\2l$", "[^l]llien", "^coad.",
            "^coag.", "^coal.", "^coax.", "(.)(?!\\1)[gq]ua(.)(?!\\2)[aeiou]", "dnt$",
            "thm$", "ier$", "iest$", "[^aeiou][aeiouy]ing$"])
    }
    
    private func populateSubSyl() throws {
        try subSyl = buildRegexesForPatterns([
            "cial", "cian", "tia", "cius", "cious",
            "gui", "ion", "iou", "sia$", ".ely$",
            "ves$", "geous$", "gious$", "[^aeiou]eful$", ".red$"])
    }
    
    private func populateExceptions() throws {
        guard let exceptionsDataAsset = NSDataAsset(name: "SyllableCounter-Exceptions") else {
            throw SyllableCounterError.MissingExceptionsDataAsset
        }
        
        guard let exceptionsList = String(data: exceptionsDataAsset.data, encoding: NSUTF8StringEncoding) else {
            throw SyllableCounterError.BadExceptionsData("Not UTF-8 encoded")
        }
        
        exceptions = [String: Int]();
        
        for exceptionItem in exceptionsList.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) {   // why it's time to ditch Cocoa legacy
            if exceptionItem.characters.count > 0 && exceptionItem.characters.first != "#" {   // skip empty lines and lines beginning with #
                let exceptionItemParts = exceptionItem.componentsSeparatedByString(" ")
                if exceptionItemParts.count != 2 {
                    throw SyllableCounterError.BadExceptionsData("Unexpected line: \(exceptionItem)")
                }
                
                let key = exceptionItemParts[1]
                let value = Int(exceptionItemParts[0])
                
                exceptions[key] = value
            }
        }
    }
    
    private func buildRegexesForPatterns(patterns: [String]) throws -> [NSRegularExpression] {
        return try patterns.map({ (pattern) -> NSRegularExpression in
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.CaseInsensitive, .AnchorsMatchLines])
                return regex
            }
            catch {
                throw SyllableCounterError.BadRegex(pattern)
            }
        })
    }
    
    // MARK: - Public methods
    
    func count(word: String) -> Int {
        if word.characters.count == 0 {
            return 0
        }
        
        if word.characters.count == 1 {
            return 1
        }
        
        var mutatedWord = word.lowercaseStringWithLocale(NSLocale(localeIdentifier: "en_US"))
                              .stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet())
        
        if let exceptionValue = exceptions[mutatedWord] {
            return exceptionValue
        }
        
        if mutatedWord.characters.last == "e" {
            mutatedWord = String(mutatedWord.characters.dropLast(1))
        }
        
        var count = 0
        var prevIsVowel = false
        
        for c in mutatedWord.characters {
            let isVowel = vowels.contains(c)
            if isVowel && !prevIsVowel {
                count += 1
            }
            prevIsVowel = isVowel
        }
        
        for pattern in addSyl {
            let matches = pattern.matchesInString(mutatedWord, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, mutatedWord.characters.count))
            if matches.count > 0 {
                count += 1
            }
        }
        
        for pattern in subSyl {
            let matches = pattern.matchesInString(mutatedWord, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, mutatedWord.characters.count))
            if matches.count > 0 {
                count -= 1
            }
        }
        
        return count > 0 ? count : 1;
    }
    
}
