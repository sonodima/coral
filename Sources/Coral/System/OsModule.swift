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

public struct OsModule {
  public let base: UInt
  public let size: UInt
  public let name: String?

  internal init(base: UInt, size: UInt, name: String?) {
    self.base = base
    self.size = size
    self.name = name
  }
}

extension OsModule: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base && lhs.size == rhs.size && lhs.name == rhs.name
  }
}

extension OsModule: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
    hasher.combine(size)
    hasher.combine(name)
  }
}

extension OsModule: CustomDebugStringConvertible {
  public var debugDescription: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.countStyle = .memory

    let base = String(base, radix: 16, uppercase: true)
    let size = formatter.string(fromByteCount: Int64(size))
    let name = name != nil ? "\"\(name!)\"" : "nil"
    return "OsModule(base: \(base), size: \(size), name: \(name))"
  }
}

extension OsModule: CustomStringConvertible {
  public var description: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useTB, .useGB, .useMB, .useKB, .useBytes]
    formatter.countStyle = .memory

    let base = String(base, radix: 16, uppercase: true)
    let size = formatter.string(fromByteCount: Int64(size))
    let name = name != nil ? name! : "nil"
    return "OsModule - Base: \(base), Size: \(size), Name: \(name)"
  }
}
