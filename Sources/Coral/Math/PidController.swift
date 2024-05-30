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

public final class PidController {
  public var kP: Double
  public var kI: Double
  public var kD: Double
  public var damp: Double

  private var _integral: Double = 0.0
  private var _prevError: Double = 0.0

  public init(kP: Double, kI: Double, kD: Double, damp: Double = 0.0) {
    self.kP = kP
    self.kI = kI
    self.kD = kD
    self.damp = damp
  }

  public func step(span: TimeSpan, error: Double) -> Double {
    let d = (error - _prevError) / span.millis
    _prevError = error
    _integral += error * span.millis
    if error * _integral < 0.0 {
      _integral *= damp
    }

    return kP * _prevError + kI * _integral + kD * d
  }

  public func reset() {
    _integral = 0.0
    _prevError = 0.0
  }
}
