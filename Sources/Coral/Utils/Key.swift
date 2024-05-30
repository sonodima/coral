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

public enum Key {
  case char(Character)
  case number(UInt8)
  case fn(UInt8)
  case numPad(UInt8)

  case left
  case up
  case right
  case down
  case leftShift
  case rightShift
  case leftControl
  case rightControl
  case leftAlt
  case rightAlt
  case capsLock
  case numLock
  case scrollLock
  case tab
  case escape
  case backspace
  case enter
  case clear
  case space
  case insert
  case delete
  case home
  case end
  case pageUp
  case pageDown
  case add
  case subtract
  case multiply
  case divide
  case separator
  case decimal
}
