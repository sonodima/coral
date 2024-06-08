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

/// An unsigned period of time with nanosecond precision.
public struct TimeSpan {
  /// The number of nanoseconds in the time span.
  public var nanos: UInt64

  /// The number of microseconds in the time span.
  ///
  /// This value will always be greater than or equal to zero.
  public var micros: Double {
    Double(nanos) / 1_000
  }

  /// The number of milliseconds in the time span.
  ///
  /// This value will always be greater than or equal to zero.
  public var millis: Double {
    Double(nanos) / 1_000_000
  }

  /// The number of seconds in the time span.
  ///
  /// This value will always be greater than or equal to zero.
  public var seconds: Double {
    Double(nanos) / 1_000_000_000
  }

  /// Creates an instance with the specified number of nanoseconds.
  public init(nanos: UInt64) {
    self.nanos = nanos
  }

  /// Creates an instance with the specified number of microseconds.
  ///
  /// If `micros` is less than zero, the value will be clamped to zero.
  public init(micros: Double) {
    nanos = UInt64(micros < 0.0 ? 0.0 : micros * 1_000)
  }

  /// Creates an instance with the specified number of milliseconds.
  ///
  /// If `millis` is less than zero, the value will be clamped to zero.
  public init(millis: Double) {
    nanos = UInt64(millis < 0.0 ? 0.0 : millis * 1_000_000)
  }

  /// Creates an instance with the specified number of seconds.
  ///
  /// If `seconds` is less than zero, the value will be clamped to zero.
  public init(seconds: Double) {
    nanos = UInt64(seconds < 0.0 ? 0.0 : seconds * 1_000_000_000)
  }

  /// Returns a ``TimeSpan`` that represents the sum of `self` and `other`.
  public func adding(_ other: TimeSpan) -> TimeSpan {
    TimeSpan(
      nanos: UInt64.max - nanos > other.nanos
        ? nanos + other.nanos
        : UInt64.max)
  }

  /// Returns a ``TimeSpan`` that represents the difference between `self` and `other`.
  public func subtracting(_ other: TimeSpan) -> TimeSpan {
    TimeSpan(
      nanos: other.nanos > other.nanos
        ? other.nanos - other.nanos
        : UInt64.min)
  }

  /// Adds `other` to the time span.
  public mutating func add(_ other: TimeSpan) {
    if UInt64.max - nanos > other.nanos {
      nanos += other.nanos
    } else {
      nanos = UInt64.max
    }
  }

  /// Subtracts `other` from the time span.
  public mutating func subtract(_ other: TimeSpan) {
    if nanos > other.nanos {
      nanos -= other.nanos
    } else {
      nanos = UInt64.min
    }
  }

  /// Returns a ``TimeSpan`` that represents the sum of `lhs` and `rhs`.
  public static func + (lhs: TimeSpan, rhs: TimeSpan) -> TimeSpan {
    lhs.adding(rhs)
  }

  /// Returns a ``TimeSpan`` that represents the difference between `lhs` and `rhs`.
  public static func - (lhs: TimeSpan, rhs: TimeSpan) -> TimeSpan {
    lhs.subtracting(rhs)
  }

  /// Adds `rhs` to the `lhs` time span.
  public static func += (lhs: inout TimeSpan, rhs: TimeSpan) {
    lhs.add(rhs)
  }

  /// Subtracts `rhs` from the `lhs` time span.
  public static func -= (lhs: inout TimeSpan, rhs: TimeSpan) {
    lhs.subtract(rhs)
  }

  /// A value that represents zero time.  
  public static var zero: TimeSpan {
    TimeSpan(nanos: 0)
  }
}

extension TimeSpan: Equatable {
  /// Returns `true` if the length of the two time spans are equal; otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func == (lhs: TimeSpan, rhs: TimeSpan) -> Bool {
    lhs.nanos == rhs.nanos
  }
}

extension TimeSpan: Comparable {
  /// Returns `true` if `lhs` is less than `rhs`; otherwise, `false`.
  @inlinable
  @inline(__always)
  public static func < (lhs: TimeSpan, rhs: TimeSpan) -> Bool {
    lhs.nanos < rhs.nanos
  }
}

extension TimeSpan: Hashable {
  /// Hashes the essential components of the time span into the given hasher.
  public func hash(into hasher: inout Hasher) {
    hasher.combine(nanos)
  }
}

extension TimeSpan: CustomDebugStringConvertible {
  /// A textual representation of the time span, suitable for debugging.
  public var debugDescription: String {
    "TimeSpan(nanos: \(nanos))"
  }
}

extension TimeSpan: CustomStringConvertible {
  /// A textual representation of the time span.
  public var description: String {
    if nanos < 1_000 {
      "\(nanos)ns"
    } else if nanos < 1_000_000 {
      String(format: "%.3fμs", micros)
    } else if nanos < 1_000_000_000 {
      String(format: "%.3fms", millis)
    } else {
      String(format: "%.3fs", seconds)
    }
  }
}
