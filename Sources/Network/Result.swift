//
//  File.swift
//  
//
//  Created by MoneyClip on 2021-02-10.
//

import Foundation

/// Result enum is a generic for any type of value
/// with success and failure case
public enum Result<T> {
    case success(T)
    case failure(Error)
}
