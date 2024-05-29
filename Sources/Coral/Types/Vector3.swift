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

public struct Vector3<T: FloatingPoint> {
  public typealias Element = T

  public var x: T
  public var y: T
  public var z: T

  @inlinable
  @inline(__always)
  public init(x: T, y: T, z: T) {
    self.x = x
    self.y = y
    self.z = z
  }

  @inlinable
  @inline(__always)
  public func dot(_ other: Self) -> T {
    x * other.x + y * other.y + z * other.z
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
  public func cross(_ other: Self) -> Self {
    Self(
      x: y * other.z - z * other.y,
      y: z * other.x - x * other.z,
      z: x * other.y - y * other.x
    )
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
    Self(x: 0, y: 0, z: 0)
  }

  @inlinable
  @inline(__always)
  public static var one: Self {
    Self(x: 1, y: 1, z: 1)
  }

  @inlinable
  @inline(__always)
  public static var up: Self {
    Self(x: 0, y: 1, z: 0)
  }

  @inlinable
  @inline(__always)
  public static var down: Self {
    Self(x: 0, y: -1, z: 0)
  }

  @inlinable
  @inline(__always)
  public static var left: Self {
    Self(x: -1, y: 0, z: 0)
  }

  @inlinable
  @inline(__always)
  public static var right: Self {
    Self(x: 1, y: 0, z: 0)
  }

  @inlinable
  @inline(__always)
  public static var forward: Self {
    Self(x: 0, y: 0, z: 1)
  }

  @inlinable
  @inline(__always)
  public static var back: Self {
    Self(x: 0, y: 0, z: -1)
  }

  @inlinable
  @inline(__always)
  public func add(_ other: Self) -> Self {
    Self(x: x + other.x, y: y + other.y, z: z + other.z)
  }

  @inlinable
  @inline(__always)
  public func sub(_ other: Self) -> Self {
    Self(x: x - other.x, y: y - other.y, z: z - other.z)
  }

  @inlinable
  @inline(__always)
  public func add(_ value: T) -> Self {
    Self(x: x + value, y: y + value, z: z + value)
  }

  @inlinable
  @inline(__always)
  public func sub(_ value: T) -> Self {
    Self(x: x - value, y: y - value, z: z - value)
  }

  @inlinable
  @inline(__always)
  public func mul(_ value: T) -> Self {
    Self(x: x * value, y: y * value, z: z * value)
  }

  @inlinable
  @inline(__always)
  public func div(_ value: T) -> Self {
    if abs(value) >= T.ulpOfOne {
      Self(x: x / value, y: y / value, z: z / value)
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
    Self(x: -value.x, y: -value.y, z: -value.z)
  }
}

extension Vector3 where T == Float {
  @inlinable
  @inline(__always)
  public func rotated(angle: Float, origin: Self = .zero) -> Self {
    let s = sin(angle)
    let c = cos(angle)
    let xs = x - origin.x
    let ys = y - origin.y
    let xr = xs * c - ys * s
    let yr = xs * s + ys * c
    return Self(x: xr + origin.x, y: yr + origin.y, z: z)
  }
}

extension Vector3 where T == Double {
  @inlinable
  @inline(__always)
  public func rotated(angle: Double, origin: Self = .zero) -> Self {
    let s = sin(angle)
    let c = cos(angle)
    let xs = x - origin.x
    let ys = y - origin.y
    let xr = xs * c - ys * s
    let yr = xs * s + ys * c
    return Self(x: xr + origin.x, y: yr + origin.y, z: z)
  }
}

extension Vector3: Equatable {
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    abs(lhs.x - rhs.x) < T.ulpOfOne
      && abs(lhs.y - rhs.y) < T.ulpOfOne
      && abs(lhs.z - rhs.z) < T.ulpOfOne
  }
}

extension Vector3: Hashable {
  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(x)
    hasher.combine(y)
    hasher.combine(z)
  }
}

extension Vector3: CustomDebugStringConvertible {
  @inlinable
  @inline(__always)
  public var debugDescription: String {
    "Vector3(x: \(x), y: \(y), z: \(z))"
  }
}

extension Vector3: CustomStringConvertible {
  @inlinable
  @inline(__always)
  public var description: String {
    "(\(x), \(y), \(z))"
  }
}

public typealias Vector3F = Vector3<Float>
public typealias Vector3D = Vector3<Double>
