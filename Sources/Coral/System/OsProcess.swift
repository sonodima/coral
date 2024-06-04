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
  /// The current process running on the system.
  static var local: Self { get }

  /// The unique identifier of the process.
  var id: UInt { get }

  /// The name of the process, or `nil` if not available.
  var name: String? { get }

  /// The processor architecture of the process.
  var architecture: Architecture { get }

  /// The main module of the process, or `nil` if not available.
  var mainModule: ProcessModule? { get }

  /// The path to the executable of the process, or `nil` if not available.
  var path: URL? { mutating get }

  /// A Boolean value indicating whether the process is still running, or `nil`
  /// if the information is not available.
  var isRunning: Bool? { get }

  /// A Boolean value indicating whether the process is running with elevated
  /// privileges, or `nil` if the information is not available.
  var isElevated: Bool? { get }

  /// Creates an instance for the process with the specified `id`.
  /// 
  /// - Parameter id: The unique identifier of the process running on the system.
  /// - Returns: An instance of ``OsProcess`` if the process is found; otherwise, `nil`.
  init?(id: UInt)

  /// Creates an instance for the first process with the specified `name`.
  /// 
  /// - Parameter name: The name of the process running on the system.
  /// - Returns: An instance of ``OsProcess`` if the process is found; otherwise, `nil`.
  init?(name: String) throws

  /// Returns an iterator over the modules loaded by the process.
  /// 
  /// - Throws: ``SystemError`` if an error occurs initializing the iterator.
  func iterateModules() throws -> ProcessModuleIterator
}

extension __OsProcess_Shared {
  /// A Boolean value indicating whether the process represents the current process.
  public var isLocal: Bool {
    id == ProcessInfo.processInfo.processIdentifier
  }

  /// Returns an iterator over the processes running on the system.
  /// 
  /// - Throws: ``SystemError`` if an error occurs initializing the iterator.
  public static func iterate() throws -> OsProcessIterator {
    try OsProcessIterator()
  }

  /// Returns an array containing all the processes running on the system.
  ///
  /// - Throws: ``SystemError`` if an error occurs while retrieving the processes.
  public static func all() throws -> [OsProcess] {
    try iterate().map { $0 }
  }

  /// Returns an array containing all the processes running on the system and matching
  /// the specified `name`.
  ///
  /// - Throws: ``SystemError`` if an error occurs while retrieving the processes.
  public static func all(name: String) throws -> [OsProcess] {
    try iterate().filter { $0.name == name }
  }

  /// Returns an array containing all the modules loaded by the process.
  ///
  /// - Throws: ``SystemError`` if an error occurs while retrieving the modules.
  public func modules() throws -> [ProcessModule] {
    try iterateModules().map { $0 }
  }

  /// Returns the module with the specified `name`, or `nil` if it is not found.
  ///
  /// - Throws: ``SystemError`` if an error occurs while retrieving the modules.
  public func module(name: String) throws -> ProcessModule? {
    try iterateModules().first { $0.name == name }
  }

  /// Returns the module at the specified `address`, or `nil` if it is not found.
  ///
  /// - Throws: ``SystemError`` if an error occurs while retrieving the modules.
  public func module(at address: UInt) throws -> ProcessModule? {
    try iterateModules().first { $0.base == address }
  }
}

extension __OsProcess_Shared /* : Hashable */ {
  /// Hashes the essential components of the process into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(name)
    // NOTE: This may have an issue if the process id gets reused by the system.
    //       In the actual isRunning implementation, we already check for the start
    //       time. We could adopt the same approach here.
  }
}

extension __OsProcess_Shared /* : CustomDebugStringConvertible */ {
  /// A textual representation of the process, suitable for debugging.
  public var debugDescription: String {
    let name = name != nil ? "\"\(name!)\"" : "nil"
    return "OsProcess(id: \(id), name: \(name))"
  }
}

extension __OsProcess_Shared /* : CustomStringConvertible */ {
  /// A textual representation of the process.
  public var description: String {
    let name = name != nil ? name! : "nil"
    return "OsProcess - ID: \(id), Name: \(name)"
  }
}
