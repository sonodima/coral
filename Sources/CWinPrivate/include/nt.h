#ifndef __CWINPRIVATE_NT_H
#define __CWINPRIVATE_NT_H

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wincred.h>

NTSYSAPI NTSTATUS NTAPI NtDelayExecution(IN BOOLEAN Alertable,
                                         IN PLARGE_INTEGER DelayInterval);

#endif // __CWINPRIVATE_NT_H
