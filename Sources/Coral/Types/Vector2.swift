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

public struct Vector2<T: FloatingPoint> {
  public typealias Element = T

  public var x: T
  public var y: T

  @inlinable
  @inline(__always)
  public init(x: T, y: T) {
    self.x = x
    self.y = y
  }

  @inlinable
  @inline(__always)
  public func dot(_ other: Self) -> T {
    x * other.x + y * other.y
  }

  @inlinable
  @inline(__always)
  public var sqrMagnitude: T {
    dot(self)
  }

  @inlinable
  @inline(__always)
  public var magnitude: T {
    sqrMagnitude.squareRoot()
  }

  @inlinable
  @inline(__always)
  public func distance(from other: Self) -> T {
    sub(other).magnitude
  }

  @inlinable
  @inline(__always)
  public var normalized: Self {
    let m = magnitude
    return m > T.ulpOfOne ? div(m) : .zero
  }

  @inlinable
  @inline(__always)
  public static var zero: Self {
    Self(x: 0, y: 0)
  }

  @inlinable
  @inline(__always)
  public static var one: Self {
    Self(x: 1, y: 1)
  }

  @inlinable
  @inline(__always)
  public static var up: Self {
    Self(x: 0, y: 1)
  }

  @inlinable
  @inline(__always)
  public static var down: Self {
    Self(x: 0, y: -1)
  }

  @inlinable
  @inline(__always)
  public static var left: Self {
    Self(x: -1, y: 0)
  }

  @inlinable
  @inline(__always)
  public static var right: Self {
    Self(x: 1, y: 0)
  }

  @inlinable
  @inline(__always)
  public func add(_ other: Self) -> Self {
    Self(x: x + other.x, y: y + other.y)
  }

  @inlinable
  @inline(__always)
  public func sub(_ other: Self) -> Self {
    Self(x: x - other.x, y: y - other.y)
  }

  @inlinable
  @inline(__always)
  public func add(_ value: T) -> Self {
    Self(x: x + value, y: y + value)
  }

  @inlinable
  @inline(__always)
  public func sub(_ value: T) -> Self {
    Self(x: x - value, y: y - value)
  }

  @inlinable
  @inline(__always)
  public func mul(_ value: T) -> Self {
    Self(x: x * value, y: y * value)
  }

  @inlinable
  @inline(__always)
  public func div(_ value: T) -> Self {
    if abs(value) >= T.ulpOfOne {
      Self(x: x / value, y: y / value)
    } else {
      .zero
    }
  }

  @inlinable
  @inline(__always)
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs.add(rhs)
  }

  @inlinable
  @inline(__always)
  public static func - (lhs: Self, rhs: Self) -> Self {
    lhs.sub(rhs)
  }

  @inlinable
  @inline(__always)
  public static func + (lhs: Self, rhs: T) -> Self {
    lhs.add(rhs)
  }

  @inlinable
  @inline(__always)
  public static func - (lhs: Self, rhs: T) -> Self {
    lhs.sub(rhs)
  }

  @inlinable
  @inline(__always)
  public static func * (lhs: Self, rhs: T) -> Self {
    lhs.mul(rhs)
  }

  @inlinable
  @inline(__always)
  public static func / (lhs: Self, rhs: T) -> Self {
    lhs.div(rhs)
  }

  @inlinable
  @inline(__always)
  public static func += (lhs: inout Self, rhs: Self) {
    lhs = lhs.add(rhs)
  }

  @inlinable
  @inline(__always)
  public static func -= (lhs: inout Self, rhs: Self) {
    lhs = lhs.sub(rhs)
  }

  @inlinable
  @inline(__always)
  public static func += (lhs: inout Self, rhs: T) {
    lhs = lhs.add(rhs)
  }

  @inlinable
  @inline(__always)
  public static func -= (lhs: inout Self, rhs: T) {
    lhs = lhs.sub(rhs)
  }

  @inlinable
  @inline(__always)
  public static func *= (lhs: inout Self, rhs: T) {
    lhs = lhs.mul(rhs)
  }

  @inlinable
  @inline(__always)
  public static func /= (lhs: inout Self, rhs: T) {
    lhs = lhs.div(rhs)
  }

  @inlinable
  @inline(__always)
  public static prefix func - (value: Self) -> Self {
    Self(x: -value.x, y: -value.y)
  }
}

extension Vector2: Equatable {
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    abs(lhs.x - rhs.x) < T.ulpOfOne
      && abs(lhs.y - rhs.y) < T.ulpOfOne
  }
}

extension Vector2: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
  }
}

extension Vector2: CustomDebugStringConvertible {
  public var debugDescription: String {
    "Vector2(x: \(x), y: \(y))"
  }
}

extension Vector2: CustomStringConvertible {
  public var description: String {
    "(\(x), \(y))"
  }
}

public typealias Vector2F = Vector2<Float>
public typealias Vector2D = Vector2<Double>
