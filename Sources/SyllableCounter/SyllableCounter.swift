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

import Foundation

class SyllableCounter {
  
  // MARK: - Shared instance
  
  static let shared = SyllableCounter()
  
  // MARK: - Private properties
  
  private var exceptions: [String: Int]!
  
  private var addSyllables: [NSRegularExpression]!
  private var subSyllables: [NSRegularExpression]!
  
  private let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
  
  // MARK: - Error enum
  
  private enum SyllableCounterError: Error {
    case badRegex(String)
    case missingExceptionsDataAsset
    case badExceptionsData(String)
  }
  
  // MARK: - Constructors
  
  init() {
    do {
      try populateAddSyllables()
      try populateSubSyllables()
      try populateExceptions()
    }
    catch SyllableCounterError.badRegex(let pattern) {
      print("Bad Regex pattern: \(pattern)")
    }
    catch SyllableCounterError.missingExceptionsDataAsset {
      print("Missing exceptions dataset.")
    }
    catch SyllableCounterError.badExceptionsData(let info) {
      print("Problem parsing exceptions dataset: \(info)")
    }
    catch {
      print("An unexpected error occured while initializing the syllable counter.")
    }
  }
  
  // MARK: - Setup
  
  private func populateAddSyllables() throws {
    try addSyllables = buildRegexes(forPatterns: [
      "ia", "riet", "dien", "iu", "io", "ii",
      "[aeiouy]bl$", "mbl$", "tl$", "sl$", "[aeiou]{3}",
      "^mc", "ism$", "(.)(?!\\1)([aeiouy])\\2l$", "[^l]llien", "^coad.",
      "^coag.", "^coal.", "^coax.", "(.)(?!\\1)[gq]ua(.)(?!\\2)[aeiou]", "dnt$",
      "thm$", "ier$", "iest$", "[^aeiou][aeiouy]ing$"])
  }
  
  private func populateSubSyllables() throws {
    try subSyllables = buildRegexes(forPatterns: [
      "cial", "cian", "tia", "cius", "cious",
      "gui", "ion", "iou", "sia$", ".ely$",
      "ves$", "geous$", "gious$", "[^aeiou]eful$", ".red$"])
  }
  
  private func populateExceptions() throws {
    // TODO
    throw SyllableCounterError.missingExceptionsDataAsset

    // guard let exceptionsDataAsset = NSDataAsset(name: "SyllableCounter-Exceptions") else {
    //   throw SyllableCounterError.missingExceptionsDataAsset
    // }
    
    // guard let exceptionsList = String(data: exceptionsDataAsset.data, encoding: String.Encoding.utf8) else {
    //   throw SyllableCounterError.badExceptionsData("Not UTF-8 encoded")
    // }
    
    // exceptions = [String: Int]()
    
    // for exception in exceptionsList.components(separatedBy: .newlines) {
    //   if !exception.isEmpty && exception.characters.first != "#" { // skip empty lines and lines beginning with #
    //     let exceptionItemParts = exception.components(separatedBy: " ")
    //     if exceptionItemParts.count != 2 {
    //       throw SyllableCounterError.badExceptionsData("Unexpected line: \(exception)")
    //     }
        
    //     let key = exceptionItemParts[1]
    //     let value = Int(exceptionItemParts[0])
        
    //     exceptions[key] = value
    //   }
    // }
  }
  
  private func buildRegexes(forPatterns patterns: [String]) throws -> [NSRegularExpression] {
    return try patterns.map { pattern -> NSRegularExpression in
      do {
        let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .anchorsMatchLines])
        return regex
      }
      catch {
        throw SyllableCounterError.badRegex(pattern)
      }
    }
  }
  
  // MARK: - Public methods
  
  func count(word: String) -> Int {
    if word.count <= 1 {
      return word.count
    }
    
    var mutatedWord = word.lowercased(with: Locale(identifier: "en_US")).trimmingCharacters(in: .punctuationCharacters)
    
    if let exceptionValue = exceptions[mutatedWord] {
      return exceptionValue
    }
    
    if mutatedWord.last == "e" {
      mutatedWord = String(mutatedWord.dropLast())
    }
    
    var count = 0
    var previousIsVowel = false
    
    for character in mutatedWord {
      let isVowel = vowels.contains(character)
      if isVowel && !previousIsVowel {
        count += 1
      }
      previousIsVowel = isVowel
    }
    
    for pattern in addSyllables {
      let matches = pattern.matches(in: mutatedWord, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: mutatedWord.count))
      if !matches.isEmpty {
        count += 1
      }
    }
    
    for pattern in subSyllables {
      let matches = pattern.matches(in: mutatedWord, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: mutatedWord.count))
      if !matches.isEmpty {
        count -= 1
      }
    }
    
    return (count > 0) ? count : 1
  }
  
}

extension String {
  
  var syllables: Int {
    return SyllableCounter.shared.count(word: self)
  }
}
