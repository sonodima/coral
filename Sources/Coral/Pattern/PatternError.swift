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

/// An error that occurs when parsing a pattern.
public enum PatternError: Error {
  /// An unexpected character was found at the given index.
  case unexpectedCharacter(index: Int, value: Character)

  /// The stream of characters ended unexpectedly.
  case endOfStream
}

extension PatternError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case let .unexpectedCharacter(index, value):
      "Unexpected character '\(value)' at index \(index)."
    case .endOfStream:
      "Stream of characters ended unexpectedly."
    }
  }
}
