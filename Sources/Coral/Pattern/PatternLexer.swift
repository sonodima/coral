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

internal final class PatternLexer {
  private let _string: String
  private var _index: String.Index

  internal var hasNext: Bool {
    _index < _string.endIndex
  }

  internal init(with string: String) {
    _string = string
    _index = string.startIndex
  }

  internal enum Token {
    case byte(UInt8)
    case wildcard
    case endOfLine
  }

  internal func next() throws -> Token {
    while hasNext {
      skipWhitespaceAndComments()
      guard hasNext else {
        return .endOfLine
      }

      return switch _string[_index] {
      case "?": try parseWildcard()
      case let char where char.isHexDigit: try parseByte()
      default:
        let position = _string.distance(from: _string.startIndex, to: _index)
        throw PatternError.unexpectedCharacter(position, _string[_index])
      }
    }

    return .endOfLine
  }

  private func advance() {
    _index = _string.index(after: _index)
  }

  private func skipWhitespaceAndComments() {
    while hasNext {
      if _string[_index].isWhitespace {
        advance()
      } else if _string[_index] == "#" {
        skipLine()
      } else {
        break
      }
    }
  }

  private func skipLine() {
    while hasNext && !_string[_index].isNewline {
      advance()
    }
  }

  private func parseWildcard() throws -> Token {
    advance()
    guard hasNext else {
      throw PatternError.endOfStream
    }

    guard _string[_index] == "?" else {
      let position = _string.distance(from: _string.startIndex, to: _index)
      throw PatternError.unexpectedCharacter(position, _string[_index])
    }

    advance()
    return .wildcard
  }

  private func parseByte() throws -> Token {
    let first = _string[_index]

    advance()
    guard hasNext else {
      throw PatternError.endOfStream
    }

    let second = _string[_index]
    guard second.isHexDigit else {
      let position = _string.distance(from: _string.startIndex, to: _index)
      throw PatternError.unexpectedCharacter(position, second)
    }

    advance()
    let value = UInt8("\(first)\(second)", radix: 16)!
    return .byte(value)
  }
}
