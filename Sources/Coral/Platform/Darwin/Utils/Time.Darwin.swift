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

#if os(macOS)

  import Darwin

  public struct Time: __Time_Shared {
    public static var ticks: UInt64 {
      var info = mach_timebase_info_data_t()
      return if mach_timebase_info(&info) == KERN_SUCCESS {
        // TODO: This may overflow, even with 64-bit arithmetic. Investigate.
        //       https://stackoverflow.com/questions/23378063/how-can-i-use-mach-absolute-time-without-overflowing
        mach_absolute_time() * UInt64(info.numer) / UInt64(info.denom)
      } else {
        // We'll just assume the scaling factor is 1:1. :shrug:
        mach_absolute_time()
      }
    }

    public static func sleep(for span: TimeSpan) -> Bool {
      var info = mach_timebase_info_data_t()
      if mach_timebase_info(&info) == KERN_SUCCESS {
        // TODO: This may overflow, even with 64-bit arithmetic. Investigate.
        //       https://stackoverflow.com/questions/23378063/how-can-i-use-mach-absolute-time-without-overflowing
        let ttw = span.nanos * UInt64(info.denom) / UInt64(info.numer)
        if mach_wait_until(mach_absolute_time() + ttw) == KERN_SUCCESS {
          return true
        }
      }

      return false
    }
  }

#endif
