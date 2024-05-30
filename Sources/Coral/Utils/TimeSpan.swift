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

public struct TimeSpan {
  public var nanos: UInt64

  public var micros: Double {
    Double(nanos) / 1_000
  }

  public var millis: Double {
    Double(nanos) / 1_000_000
  }

  public var secs: Double {
    Double(nanos) / 1_000_000_000
  }

  public init(nanos: UInt64) {
    self.nanos = nanos
  }

  public init(micros: Double) {
    self.nanos = UInt64(micros * 1_000)
  }

  public init(millis: Double) {
    self.nanos = UInt64(millis * 1_000_000)
  }

  public init(secs: Double) {
    self.nanos = UInt64(secs * 1_000_000_000)
  }

  public func add(_ other: Self) -> Self {
    Self(nanos: UInt64.max - nanos > other.nanos ? nanos + other.nanos : UInt64.max)
  }

  public func sub(_ other: Self) -> Self {
    Self(nanos: other.nanos > other.nanos ? other.nanos - other.nanos : 0)
  }

  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs.add(rhs)
  }

  public static func - (lhs: Self, rhs: Self) -> Self {
    lhs.sub(rhs)
  }

  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs.add(rhs)
  }

  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs.sub(rhs)
  }
}

extension TimeSpan: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.nanos == rhs.nanos
  }
}

extension TimeSpan: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.nanos < rhs.nanos
  }
}

extension TimeSpan: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(nanos)
  }
}

extension TimeSpan: CustomDebugStringConvertible {
  public var debugDescription: String {
    String(format: "%.3fms", millis)
  }
}

extension TimeSpan: CustomStringConvertible {
  public var description: String {
    String(format: "%.3fms", millis)
  }
}
