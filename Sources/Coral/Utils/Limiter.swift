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

public final class Limiter {
  public enum Mode {
    case block
    case skip
  }

  public var target: UInt
  public var mode: Mode

  private var last: UInt64?

  public init(target: UInt = 60, mode: Mode = .block) {
    self.target = target
    self.mode = mode
  }

  public func limit(_ block: (TimeSpan?) throws -> Void) rethrows {
    var elapsed = timeFromLast()
    let step = 1000.0 / Double(target)
    
    // If it's the first run, just execute the block and return.
    if elapsed == nil {
      last = Time.now
      try block(nil)
      return
    }

    // Thread scheduling is not perfect, and the time it takes to wake up from sleep
    // can vary. To account for this, we chunk the sleep time into multiple smaller
    // intervals to increase the chance of waking up on time.
    //
    // This takes a bit more CPU time, but it's wildly more accurate than just sleeping
    // for the full duration.
    if mode == .block {
      var remaining = step - elapsed!.millis

      last = Time.now
      while remaining > 0.1 {
        let ttw = TimeSpan(millis: remaining * 0.8)
        Time.sleep(for: ttw)

        elapsed = timeFromLast()
        remaining = step - (elapsed?.millis ?? 0.0)
      }
    }

    if mode == .skip && elapsed!.millis < step {
      return
    }

    last = Time.now
    try block(elapsed)
  }

  private func timeFromLast() -> TimeSpan? {
    last.map { TimeSpan(nanos: Time.now - $0) }
  }
}
