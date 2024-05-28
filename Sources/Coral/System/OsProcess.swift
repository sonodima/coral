// Copyright (C) 2024 sonodima
// This file is part of the Coral project.
//
// Coral is free software: you can redistribute it and/or modify it under the terms of
// the GNU General Public License as published by the Free Software Foundation, either
// version 3 of the License, or (at your option) any later version.
//
// Coral is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with Coral.
// If not, see <https://www.gnu.org/licenses/>.

import Foundation

public protocol __OsProcess_Shared:
  Equatable, Hashable,
  CustomDebugStringConvertible, CustomStringConvertible
{
  static var local: Self { get }

  var id: UInt { get }
  var name: String? { get }
  var architecture: Architecture { get }

  var mainModule: OsModule? { mutating get }
  var path: URL? { mutating get }
  var isRunning: Bool? { get }
  var isElevated: Bool? { get }

  init?(id: UInt)
  init?(name: String) throws

  static func iterate() throws -> OsProcessIterator

  func modules() throws -> [OsModule]
  func module(name: String) throws -> OsModule?
  func module(at address: UInt) throws -> OsModule?
}

extension __OsProcess_Shared {
  public var isLocal: Bool {
    id == ProcessInfo.processInfo.processIdentifier
  }

  public static func all() throws -> [OsProcess] {
    try iterate().map { $0 }
  }

  public static func all(name: String) throws -> [OsProcess] {
    try iterate().filter { $0.name == name }
  }

  public func module(name: String) throws -> OsModule? {
    try modules().first { $0.name == name }
  }

  public func module(at address: UInt) throws -> OsModule? {
    try modules().first { $0.base == address }
  }
}

extension __OsProcess_Shared /* : Hashable */ {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension __OsProcess_Shared /* : CustomDebugStringConvertible */ {
  public var debugDescription: String {
    let name = name != nil ? "\"\(name!)\"" : "nil"
    return "OsProcess(id: \(id), name: \(name))"
  }
}

extension __OsProcess_Shared /* : CustomStringConvertible */ {
  public var description: String {
    let name = name != nil ? name! : "nil"
    return "OsProcess - ID: \(id), Name: \(name)"
  }
}
