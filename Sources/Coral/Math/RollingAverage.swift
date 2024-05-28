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

public final class RollingAverage {
  private var _values: [Double]
  private var _availablePoints: UInt = 0
  private var _head: Int = 0
  private var _sum: Double = 0.0

  public var value: Double {
    if _availablePoints > 0 {
      _sum / Double(_availablePoints)
    } else {
      _sum
    }
  }

  public init(window: UInt = 60) {
    _values = [Double](repeating: 0.0, count: Int(window))
  }

  public func insert(value: Double) {   
    _sum -= _values[_head]
    _sum += value
    _values[_head] = value
    _head = (_head + 1) % _values.count
    if _availablePoints < UInt(_values.count) {
      _availablePoints += 1
    }
  }

  public func clear() {
    _values.removeAll(keepingCapacity: true)
    _availablePoints = 0
    _head = 0
    _sum = 0.0
  }
}
