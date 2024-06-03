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

/// A sequence of bytes to be matched in a data set, that can be parsed from a
/// signature string.
public struct Pattern {
  /// The list of bytes defining the pattern.
  public let data: [UInt8?]

  /// Creates an instance from the given `data`.
  ///
  /// - Parameter data: The list of bytes defining the pattern.
  ///
  /// Each byte is represented by an optional `UInt8` value. If the value is `nil`,
  /// the byte is a wildcard.
  public init(from data: [UInt8?]) {
    self.data = data
  }

  /// Creates an instance parsing the given `signature` string.
  ///
  /// - Parameter signature: The string defining the pattern.
  ///
  /// Signatures are strings of hexadecimal bytes _(e.g. 48)_ or wildcards _(e.g. ??)_
  /// that represent a pattern to be matched in a sequence of bytes.
  ///
  /// For example, the signature `"48 8B 05 ?? ?? ?? ?? E8"` will match all x86-64
  /// instructions `"mov rax, qword ptr [rip + ??]"` followed by a `call` instruction.
  ///
  /// You can use spaces to separate bytes and wildcards, but they are not required.
  /// Multiple lines are also allowed to improve readability, as well as comments
  /// using the `#` character.
  ///
  /// - Throws: `Pattern.Error` if the signature is invalid.
  public init(from signature: String) throws {
    var data: [UInt8?] = []

    let lexer = PatternLexer(input: signature)
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

  /// Returns an iterator that searches for the pattern in the given `data`.
  ///
  /// You can use the iterator to find all occurrences of the pattern in the
  /// data, or to iterate over them as needed.
  ///
  /// ```swift
  /// for match in pattern.scan(in: data) {
  ///   print("Found at offset \(match)")
  ///   break
  /// }
  /// ```
  public func scan(in data: ContiguousArray<UInt8>) -> PatternIterator {
    PatternIterator(pattern: self, in: data)
  }

  /// Returns the first occurrence of the pattern in the given `data` if it exists;
  /// otherwise, `nil`.
  public func find(in data: ContiguousArray<UInt8>) -> UInt? {
    scan(in: data).next()
  }
}

extension Pattern: Equatable {
  /// Returns `true` if the two patterns contain the same data; otherwise, `false`.
  public static func == (lhs: Pattern, rhs: Pattern) -> Bool {
    lhs.data == rhs.data
  }
}

extension Pattern: Hashable {
  /// Hashes the essential components of the pattern into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.data)
  }
}

extension Pattern: CustomDebugStringConvertible {
  /// A textual representation of the pattern, suitable for debugging.
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
  /// A textual representation of the pattern.
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
