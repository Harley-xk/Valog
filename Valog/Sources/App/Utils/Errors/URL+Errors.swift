//
//  URL+Errors.swift
//
//
//  Created by Harley-xk on 2020/5/5.
//

import Foundation

public extension URL {
    enum Error: Int, Swift.Error {
        case fileIsNotDirectory

        case fileDoesNotExist = -1100
        case fileIsDirectory = -1101
        case noPermissionsToReadFile = -1102
        case dataLengthExceedsMaximum = -1103
    }
}
