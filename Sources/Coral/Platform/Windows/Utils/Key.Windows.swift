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

  extension Key {
    internal var system: Int32? {
      switch self {
      case .char(let value):
        guard var ascii = value.asciiValue else {
          return nil
        }

        if value.isUppercase {
          ascii &= 0xDF
        }

        return ascii >= 0x41 && ascii <= 0x5A
          ? Int32(ascii)
          : nil

      case .number(let value):
        return if value >= 0 && value <= 9 {
          0x30 + Int32(value)
        } else {
          nil
        }
      
      case .fn(let value):
        return if value >= 1 && value <= 24 {
          VK_F1 + Int32(value - 1)
        } else {
          nil
        }

      case .numPad(let value):
        return if value >= 0 && value <= 9 {
          VK_NUMPAD0 + Int32(value)
        } else {
          nil
        }

      case .left: return VK_LEFT
      case .right: return VK_RIGHT
      case .up: return VK_UP
      case .down: return VK_DOWN
      case .leftShift: return VK_LSHIFT
      case .rightShift: return VK_RSHIFT
      case .leftControl: return VK_LCONTROL
      case .rightControl: return VK_RCONTROL
      case .leftAlt: return VK_LMENU
      case .rightAlt: return VK_RMENU
      case .capsLock: return VK_CAPITAL
      case .numLock: return VK_NUMLOCK
      case .scrollLock: return VK_SCROLL
      case .tab: return VK_TAB
      case .escape: return VK_ESCAPE
      case .backspace: return VK_BACK
      case .enter: return VK_RETURN
      case .clear: return VK_CLEAR
      case .space: return VK_SPACE
      case .insert: return VK_INSERT
      case .delete: return VK_DELETE
      case .home: return VK_HOME
      case .end: return VK_END
      case .pageUp: return VK_PRIOR
      case .pageDown: return VK_NEXT
      case .add: return VK_ADD
      case .subtract: return VK_SUBTRACT
      case .multiply: return VK_MULTIPLY
      case .divide: return VK_DIVIDE
      case .separator: return VK_SEPARATOR
      case .decimal: return VK_DECIMAL
      }
    }
  }

#endif
