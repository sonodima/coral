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

#if os(Windows)

  import WinSDK

  public class Input: __Input_Shared {
    public static func isDown(key: Key) -> Bool? {
      if let code = key.system {
        GetAsyncKeyState(code) & (1 << 15) != 0
      } else {
        nil
      }
    }

    public static func moveMouse(to point: Vector2D) -> Bool {
      var scaled = point * 65536
      scaled.x /= Double(GetSystemMetrics(SM_CXSCREEN))
      scaled.y /= Double(GetSystemMetrics(SM_CYSCREEN))

      var input = INPUT()
      input.type = DWORD(INPUT_MOUSE)
      input.mi.dwFlags = DWORD(MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE)
      input.mi.dx = LONG(scaled.x)
      input.mi.dy = LONG(scaled.y)
      let size = MemoryLayout<INPUT>.size
      return SendInput(1, &input, Int32(size)) != 0
    }

    public static func moveMouse(by delta: Vector2D) -> Bool {
      var input = INPUT()
      input.type = DWORD(INPUT_MOUSE)
      input.mi.dwFlags = DWORD(MOUSEEVENTF_MOVE)
      input.mi.dx = LONG(delta.x)
      input.mi.dy = LONG(delta.y)
      let size = MemoryLayout<INPUT>.size
      return SendInput(1, &input, Int32(size)) != 0
    }
  }

#endif
