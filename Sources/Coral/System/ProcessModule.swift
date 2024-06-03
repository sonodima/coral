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

/// A module that is loaded into a process.
/// 
/// This structure only provides information about the module's memory and details.
/// 
/// To access its memory, you need to convert it to a ``MemRange``, feeding it to
/// a ``MemView``.
public struct ProcessModule {
  /// The base address of the module.
  public let base: UInt
  
  /// The size of the module in bytes.
  public let size: UInt
  
  /// The full path to the module on disk, or `nil` if not available.
  public let path: URL?

  /// The name of the module, or `nil` if not available.
  public let name: String?

  @inlinable
  @inline(__always)
  internal init(base: UInt, size: UInt, path: URL?, name: String?) {
    self.base = base
    self.size = size
    self.path = path
    self.name = name
  }
}

extension ProcessModule: Equatable {
  /// Returns `true` if the components of the two modules are equal; otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base && lhs.size == rhs.size
      && lhs.path == rhs.path && lhs.name == rhs.name
  }
}

extension ProcessModule: Hashable {
  /// Hashes the essential components of the module into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
    hasher.combine(size)
    hasher.combine(path)
    hasher.combine(name)
  }
}

extension ProcessModule: CustomDebugStringConvertible {
  /// A textual representation of the module, suitable for debugging.
  public var debugDescription: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.allowsNonnumericFormatting = false
    formatter.countStyle = .memory

    let base = String(base, radix: 16, uppercase: true)
    let size = formatter.string(fromByteCount: Int64(size))
    let name = name != nil ? "\"\(name!)\"" : "nil"
    return "ProcessModule(base: \(base), size: \(size), name: \(name))"
  }
}

extension ProcessModule: CustomStringConvertible {
  /// A textual representation of the module.
  public var description: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.allowsNonnumericFormatting = false
    formatter.countStyle = .memory

    let base = String(base, radix: 16, uppercase: true)
    let size = formatter.string(fromByteCount: Int64(size))
    let name = name ?? "nil"
    return "ProcessModule - Base: \(base), Size: \(size), Name: \(name)"
  }
}
