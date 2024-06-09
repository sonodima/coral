#ifndef _CWINPRIVATE_NT_H
#define _CWINPRIVATE_NT_H

#include <ntdef.h>

NTSYSAPI NTSTATUS NTAPI
NtDelayExecution(IN BOOLEAN Alertable, IN PLARGE_INTEGER DelayInterval);

#endif // _CWINPRIVATE_NT_H
