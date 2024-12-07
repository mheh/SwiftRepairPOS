//
//  AppError.swift
//  SwiftRepairPOS
//
//  Created by Milo Hehmsoth on 12/6/24.
//

// From madsodgaard
// https://github.com/madsodgaard/vapor-auth-template/blob/main/Sources/App/Errors/AppError.swift

import Vapor

protocol AppError: AbortError, DebuggableError {
}
