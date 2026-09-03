<div align="center">

# SMM Register 0x3a & DXE Lockdown Engine
### Low-Level Ring -2 Firmware Security & BIOS Lock Enforcement in Pure Assembly

[![Assembly](https://img.shields.io/badge/Language-x86__64%20ASM-purple?style=flat&logo=assembly&logoColor=white)](https://en.wikipedia.org/wiki/Assembly_language)
[![Platform](https://img.shields.io/badge/Platform-UEFI%20%2F%20SMM-0078D6?style=flat&logo=windows&logoColor=white)](https://en.wikipedia.org/wiki/System_Management_Mode)
[![Privilege](https://img.shields.io/badge/Privilege-Ring%20-2-critical?style=flat)]()

</div>

---

## Overview

A bare-metal, pure Assembly implementation executing during the **DXE (Driver Execution Environment)** phase of UEFI firmware initialization. This low-level driver specifically targets and locks **MSR 0x3A (FEATURE_CONTROL)** and critical chipset configuration registers, ensuring that BIOS protection mechanisms and trusted execution features are permanently locked down before the operating system boots.

---

## Technical Architecture & Mechanism

Operating at **Ring -2** within System Management Mode (SMM), this component prevents post-boot modifications to essential CPU security configuration registers:

1. **MSR 0x3A (FEATURE_CONTROL) Enforcement:** Reads the IA32_FEATURE_CONTROL MSR, ensures necessary security bits (such as Lock Bit and SMX/VMX enablement) are asserted, and sets the **Lock Bit (Bit 0)** to prevent subsequent modifications from higher privilege rings (Ring 0 / Kernel).
2. **DXE Phase Synchronization:** Executes early enough in the pre-OS stage to lock features before execution control hands off to the bootloader.
3. **Atomic Execution & Cache Flushing:** Utilizes hardware serialization instructions (`cli`, `wbinvd`) to ensure register states propagate securely across multi-core socket architectures.

---

## Assembly Implementation Concept

```assembly
; ==============================================================================
; MSR 0x3A & SMM Lockdown Routine (Pure x86_64 Assembly)
; Target: DXE Phase Pre-OS Initialization
; ==============================================================================

.code

PUBLIC LockMSR0x3AAndSMM

LockMSR0x3AAndSMM PROC
    ; Clear direction flag
    cld

    ; Disable interrupts for atomic MSR operation
    cli

    ; Read IA32_FEATURE_CONTROL MSR (0x3A)
    mov ecx, 3Ah            ; MSR address 0x3A
    rdmsr                   ; Read MSR into EDX:EAX

    ; Ensure the Lock Bit (Bit 0) and basic enablement flags are set
    ; Bit 0: Lock bit, Bit 1: Enable VMX outside SMX, Bit 2: Enable VMX inside SMX
    or eax, 00000005h       ; Set appropriate bits
    or eax, 00000001h       ; Force Lock Bit (EXTREMLY CRITICAL: irreversible until next reset)

    ; Write back modified configuration to MSR 0x3A
    wrmsr                   

    ; Flush CPU caches to ensure register state commitment
    wbinvd                  

    ; Restore interrupt flag
    sti
    ret
LockMSR0x3AAndSMM ENDP

END
