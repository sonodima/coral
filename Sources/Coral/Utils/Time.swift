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

public protocol __Time_Shared {
  /// The number of ticks of the system's absolute clock.
  static var now: UInt64 { get }

  /// Interrupts the execution of the current thread for the specified amount of time.
  /// 
  /// - Returns: `true` if the thread was successfully put to sleep; otherwise, `false`.
  ///
  /// If possible, this function will attempt to use the highest resolution sleep
  /// available on the platform.
  ///
  /// Keep in mind that for high throughput applications, you should probably consider
  /// using asynchronous code instead of sleeping the thread.
  @discardableResult
  static func sleep(for span: TimeSpan) -> Bool
}

extension __Time_Shared {
  /// Executes the given `block` measuring the time it takes to complete with the
  /// highest resolution available on the platform.
  @inlinable
  @inline(__always)
  public static func measure<R>(_ block: () throws -> R) rethrows -> (R, TimeSpan) {
    let start = now
    let result = try block()
    let elapsed = TimeSpan(nanos: now - start)
    return (result, elapsed)
  }

  /// Executes the given `block` measuring the time it takes to complete with the
  /// highest resolution available on the platform.
  @inlinable
  @inline(__always)
  public static func measure(_ block: () throws -> Void) rethrows -> TimeSpan {
    try measure(block).1
  }
}
