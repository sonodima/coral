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
  import Foundation

  public struct Time: __Time_Shared {
    public static func sleep(for span: TimeSpan) {
      var info = mach_timebase_info_data_t()
      if mach_timebase_info(&info) == KERN_SUCCESS {
        let ttw = span.nanos * UInt64(info.denom) / UInt64(info.numer)
        if mach_wait_until(mach_absolute_time() + ttw) == KERN_SUCCESS {
          return
        }
      }

      Thread.sleep(forTimeInterval: TimeInterval(span.secs))
    }
  }

#endif
