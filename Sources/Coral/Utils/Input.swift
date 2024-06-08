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

public protocol __Input_Shared {
  /// Returns `true` if `key` is currently pressed, `false` if it is not, or `nil` if
  /// the state cannot be determined.`
  static func isDown(key: Key) -> Bool?

  /// Moves the position of the mouse cursor to `point`.
  /// 
  /// - Returns: `true` if the operation was successful, `false` otherwise.
  static func moveMouse(to point: Vector2D) -> Bool
  
  /// Moves the position of the mouse cursor by `delta` pixels.
  /// 
  /// - Returns: `true` if the operation was successful, `false` otherwise.
  /// 
  /// You can use this function to simulate mouse movement in a program that locks the
  /// cursor.
  /// 
  /// - Note: Depending on the operating system, this function may behave differently.
  static func moveMouse(by delta: Vector2D) -> Bool
}
