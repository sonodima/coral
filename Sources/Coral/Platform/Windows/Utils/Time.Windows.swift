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

  import CWinPrivate

  /// Provides time-related functionality implemented using the system's
  /// highest-resolution timing functions.
  public struct Time: __Time_Shared {
    public static var now: UInt64 {
      var counter = LARGE_INTEGER()
      QueryPerformanceCounter(&counter)

      // NOTE: I'm not sure if this may result in some unexpected behavior due to the
      //       fact that we are casting the scale to an integer.
      let scale = 1e9 / Double(_frequency)
      return UInt64(counter.QuadPart) * UInt64(scale)
    }

    @discardableResult
    public static func sleep(for span: TimeSpan) -> Bool {
      var li = LARGE_INTEGER()
      li.QuadPart = -Int64(span.nanos / 100)
      return NtDelayExecution(0 /* FALSE */, &li) == 0 /* NT_SUCCESS */
    }

    @discardableResult
    public static func increasePrecision() -> Bool {
      timeBeginPeriod(1) == TIMERR_NOERROR
    }

    @discardableResult
    public static func restorePrecision() -> Bool {
      timeEndPeriod(1) == TIMERR_NOERROR
    }

    private static var _frequency: UInt64 = {
      var frequency = LARGE_INTEGER()
      QueryPerformanceFrequency(&frequency)
      return UInt64(frequency.QuadPart)
    }()
  }

#endif
