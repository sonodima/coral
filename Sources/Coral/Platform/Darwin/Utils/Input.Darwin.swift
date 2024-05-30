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

#if os(macOS)

  import CoreGraphics

  public final class Input: __Input_Shared {
    public static func isDown(key: Key) -> Bool? {
      if #available(macOS 10.15, *) {
        if !CGRequestListenEventAccess() {
          return nil
        }
      }

      return if let code = key.system {
        CGEventSource.keyState(.combinedSessionState, key: code)
      } else {
        nil
      }
    }

    public static func moveMouse(to point: Vector2D) -> Bool {
      if #available(macOS 10.15, *) {
        if !CGRequestPostEventAccess() {
          return false
        }
      }

      let event = CGEvent(
        mouseEventSource: nil,
        mouseType: .mouseMoved,
        mouseCursorPosition: CGPoint(x: point.x, y: point.y),
        mouseButton: .left)
      event?.post(tap: .cghidEventTap)
      return event != nil
    }

    public static func moveMouse(by delta: Vector2D) -> Bool {
      if #available(macOS 10.15, *) {
        if !CGRequestPostEventAccess() {
          return false
        }
      }

      // This is designed to be used to send mouse input in games, and it will not
      // actually move the cursor.
      //
      // Oh, and don't call it too often, or the input queue will start to fill up,
      // resulting in annoyances ranging from delayed input to system freeze.
      // Using the screen's refresh rate as a guideline is a good idea and has worked
      // well in my testing.
      guard let event = CGEvent(source: nil) else {
        return false
      }

      event.type = .mouseMoved
      event.setDoubleValueField(.mouseEventDeltaX, value: delta.x)
      event.setDoubleValueField(.mouseEventDeltaY, value: delta.y)
      event.post(tap: .cghidEventTap)
      return true
    }
  }

#endif
