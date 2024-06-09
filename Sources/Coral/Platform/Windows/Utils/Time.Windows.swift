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

  public struct Time: __Time_Shared {
    public static var now: UInt64 {
      var frequency = LARGE_INTEGER()
      QueryPerformanceFrequency(&frequency)

      var counter = LARGE_INTEGER()
      QueryPerformanceCounter(&counter)


      let denom = UInt64(frequency.QuadPart)
      // let denom = UInt64(frequency.QuadPart) / 1_000_000_000
      // return UInt64(counter.QuadPart) / denom
      return UInt64(counter.QuadPart) * 100
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
  }

#endif
