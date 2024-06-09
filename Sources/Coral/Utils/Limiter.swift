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

/// A utility to limit the execution of a block to a certain rate.
public final class Limiter {
  /// The strategy to use to limit the execution of a block.
  public enum Strategy {
    /// Sleep for the remaining time to reach the target rate.
    ///
    /// This is accurate enough for most cases, but it's not perfect due to the nature
    /// of thread scheduling.
    case sleep

    /// Skip the execution if it enough time has not passed since the last execution.
    ///
    /// This is very easy on the CPU, but you must already be running on a loop for
    /// it to be effective.
    case skip
  }

  private var last: UInt64?

  /// The number of times the block can be executed per second.
  public var target: UInt

  /// The strategy _(implementation)_ to use to limit the execution of the block.
  public var strategy: Strategy

  /// Creates an instance with the given `target` rate and `strategy`.
  public init(target: UInt = 60, strategy: Strategy = .sleep) {
    self.target = target
    self.strategy = strategy
  }

  /// Limits the execution of `block` to the target rate using the specified strategy.
  ///
  /// Unless it's the first run, `block` is called with the elapsed time since the last
  /// execution.
  public func limit(_ block: (_ dt: TimeSpan?) throws -> Void) rethrows {
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
    if strategy == .sleep {
      var remaining = step - elapsed!.millis

      last = Time.now
      while remaining > 0.66 {
        let ttw = TimeSpan(millis: remaining * 0.8)
        Time.sleep(for: ttw)

        elapsed = timeFromLast()
        remaining = step - (elapsed?.millis ?? 0.0)
      }
    }

    if strategy == .skip && elapsed!.millis < step {
      return
    }

    last = Time.now
    try block(elapsed)
  }

  private func timeFromLast() -> TimeSpan? {
    last.map { TimeSpan(nanos: Time.now - $0) }
  }
}
