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

public enum TimeDuration {
  case secs(Int64)
  case millis(Int64)
  case micros(Int64)
  case nanos(Int64)
}

public extension TimeDuration {
  var ticks: Int64 {
    switch self {
    case .secs(let value): value * 1_000_000_000
    case .millis(let value): value * 1_000_000
    case .micros(let value): value * 1_000
    case .nanos(let value): value
    }
  }
}

extension TimeDuration: CustomStringConvertible {
  public var description: String {
    switch self {
    case .secs(let value): "\(value)s"
    case .millis(let value): "\(value)ms"
    case .micros(let value): "\(value)μs"
    case .nanos(let value): "\(value)ns"
    }
  }
}

extension TimeDuration: Equatable {
  public static func == (lhs: TimeDuration, rhs: TimeDuration) -> Bool {
    lhs.ticks == rhs.ticks
  }
}

extension TimeDuration: Comparable {
  public static func < (lhs: TimeDuration, rhs: TimeDuration) -> Bool {
    lhs.ticks < rhs.ticks
  }
}

extension TimeDuration: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ticks)
  }
}
