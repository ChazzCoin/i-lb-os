//
//  File.swift
//  
//
//  Created by Charles Romeo on 4/13/24.
//

import Foundation
import SwiftUI

public extension String {
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }
    
    

    // MARK: - Formatting

    /// Trims white space and new lines from the string.
    var trimmed: String {
       return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns a string with the first letter capitalized.
    var capitalizedFirst: String {
       return prefix(1).capitalized + dropFirst()
    }

    /// Replaces spaces with dashes.
    var dashed: String {
       return replacingOccurrences(of: " ", with: "-")
    }

    /// Converts a string to URL-safe format.
    var urlEncoded: String {
       return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? self
    }

    // MARK: - Miscellaneous

    /// Reverses the string.
    var reversed: String {
       return String(self.reversed())
    }

    /// Checks if the string is palindrome.
    var isPalindrome: Bool {
       let cleaned = self.lowercased().replacingOccurrences(of: "\\W", with: "", options: .regularExpression)
       return cleaned == String(cleaned.reversed())
    }

    /// Converts a string to Base64 encoding.
    var base64Encoded: String? {
       return self.data(using: .utf8)?.base64EncodedString()
    }

    /// Converts a Base64 encoded string to a regular string.
    var base64Decoded: String? {
       guard let data = Data(base64Encoded: self) else { return nil }
       return String(data: data, encoding: .utf8)
    }

    // MARK: - Substrings

    /// Returns a substring from the beginning to the given index.
    func substring(to index: Int) -> String {
       return String(self.prefix(index))
    }

    /// Returns a substring from the given index to the end.
    func substring(from index: Int) -> String {
       return String(self.suffix(from: self.index(self.startIndex, offsetBy: index)))
    }

    // MARK: - Character Removal

    /// Removes a specified character from the string.
    func removing(character: Character) -> String {
       return filter { $0 != character }
    }

    // MARK: - Localization

    /// Localizes the string using NSLocalizedString.
    var localized: String {
       return NSLocalizedString(self, comment: "")
    }
}


public extension String {
    
    // MARK: - Email Verification
    
    /// Checks if the string is a valid email format.
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    // MARK: - Numeric Verification
    
    /// Checks if the string contains only numbers.
    var isNumeric: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    // MARK: - Phone Number Verification
    
    /// Checks if the string is a valid phone number.
    var isValidPhoneNumber: Bool {
        let phoneRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self)
    }
    
    // MARK: - Password Strength Verification
    
    /// Checks if the password is strong. Password must be at least 8 characters, include uppercase and lowercase letters, a number, and a special character.
    var isStrongPassword: Bool {
        let passwordRegEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$&*]).{8,}"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: self)
    }
    
    // MARK: - URL Verification
    
    /// Checks if the string is a valid URL.
    var isValidURL: Bool {
        if let url = URL(string: self), UIApplication.shared.canOpenURL(url) {
            return true
        }
        return false
    }
    
    // MARK: - Postal Code Verification
    
    /// Checks if the string is a valid US ZIP code.
    var isValidUSZIPCode: Bool {
        let zipRegEx = "^\\d{5}(-\\d{4})?$"
        let zipPred = NSPredicate(format: "SELF MATCHES %@", zipRegEx)
        return zipPred.evaluate(with: self)
    }
    
    // MARK: - Social Security Number Verification
    
    /// Checks if the string is a valid US Social Security Number (SSN).
    var isValidSSN: Bool {
        let ssnRegEx = "^\\d{3}-\\d{2}-\\d{4}$"
        let ssnPred = NSPredicate(format: "SELF MATCHES %@", ssnRegEx)
        return ssnPred.evaluate(with: self)
    }

    // MARK: - IP Address Verification
    
    /// Checks if the string is a valid IPv4 address.
    var isValidIPv4: Bool {
        let ipRegEx = "^((25[0-5]|2[0-4]\\d|[01]?\\d\\d?)\\.){3}(25[0-5]|2[0-4]\\d|[01]?\\d\\d?)$"
        let ipPred = NSPredicate(format: "SELF MATCHES %@", ipRegEx)
        return ipPred.evaluate(with: self)
    }
    
    // MARK: - Credit Card Number Verification
    
    /// Checks if the string is a valid credit card number.
    var isValidCreditCardNumber: Bool {
        let cardRegEx = "^(?:4[0-9]{12}(?:[0-9]{3})?          // Visa\n" +
                        "|  5[1-5][0-9]{14}                        // MasterCard\n" +
                        "|  3[47][0-9]{13}                         // American Express\n" +
                        "|  3(?:0[0-5]|[68][0-9])[0-9]{11}         // Diners Club\n" +
                        "|  6(?:011|5[0-9]{2})[0-9]{12}            // Discover\n" +
                        "|  (?:2131|1800|35\\d{3})\\d{11})$"
        let cardPred = NSPredicate(format: "SELF MATCHES %@", cardRegEx)
        return cardPred.evaluate(with: self)
    }
}
