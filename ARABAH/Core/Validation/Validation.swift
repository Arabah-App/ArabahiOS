//
//  Validation.swift
//  AdventureShare
//
//  Created by cql on 23/03/20.
//  Copyright © 2020 cqljs. All rights reserved.
//

import UIKit

class Validation {
 
    public func validateEmailId(emailID: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let trimmedString = emailID.trimmingCharacters(in: .whitespaces)
        let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValidateEmail = validateEmail.evaluate(with: trimmedString)
        return isValidateEmail
    }
    
}

