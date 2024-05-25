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

public struct Pattern {
  public let data: [UInt8?]

  public init(from data: [UInt8?]) {
    self.data = data
  }

  public init(from string: String) throws {
    var data: [UInt8?] = []

    let lexer = PatternLexer(with: string)
    while lexer.hasNext {
      let token = try lexer.next()
      switch token {
      case .byte(let byte): data.append(byte)
      case .wildcard: data.append(nil)
      case .endOfLine: break
      }
    }

    self.data = data
  }

  public func scan(in data: ContiguousArray<UInt8>) -> PatternIterator {
    PatternIterator(pattern: self, in: data)
  }

  public func find(in data: ContiguousArray<UInt8>) -> Int? {
    var iterator = scan(in: data)
    return iterator.next()
  }
}

extension Pattern: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.data == rhs.data
  }
}

extension Pattern: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.data)
  }
}

extension Pattern: CustomDebugStringConvertible {
  public var debugDescription: String {
    let bytes = data.map {
      if let byte = $0 {
        String(format: "%02X", byte)
      } else {
        "??"
      }
    }.joined(separator: " ")

    return "Pattern(from: \"\(bytes)\")"
  }
}

extension Pattern: CustomStringConvertible {
  public var description: String {
    data.map {
      if let byte = $0 {
        String(format: "%02X", byte)
      } else {
        "??"
      }
    }.joined(separator: " ")
  }
}
