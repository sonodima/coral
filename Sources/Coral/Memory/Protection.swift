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

/// The protection level of a memory region. 
public enum Protection {
  /// No access is allowed.
  case none
  
  /// Read-only access is allowed.
  /// 
  /// An attempt to write to the region will result in an access violation.
  case r

  /// Execute-only access is allowed.
  case x

  /// Read and write access is allowed.
  case rw

  /// Read and execute access is allowed.
  ///
  /// An attempt to write to the region will result in an access violation.
  case rx

  /// Read, write, and execute access is allowed.
  case rwx
}
