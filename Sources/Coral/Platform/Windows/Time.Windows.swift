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

  import Foundation
  import WinSDK

  @_silgen_name("NtDelayExecution")
  private func NtDelayExecution(
    _ alertable: WindowsBool,
    _ interval: PLARGE_INTEGER
  ) -> NTSTATUS

  public struct Time: __Time_Shared {
    public static func sleep(for duration: TimeDuration) {
      var li = LARGE_INTEGER()
      li.QuadPart = -(duration.ticks / 100)
      guard NtDelayExecution(false, &li) != 0 /* NT_SUCCESS */ else {
        return
      }

      let interval = TimeInterval(duration.ticks / 1_000_000)
      Thread.sleep(forTimeInterval: interval)
    }

    @discardableResult
    public static func increasePrecision() -> Bool {
      timeBeginPeriod(1) == TIMERR_NOERROR
    }

    @discardableResult
    public static func restorePrecision() -> Bool {
      timeEndPeriod(1) == TIMERR_NOERROR
    }
  }

#endif
