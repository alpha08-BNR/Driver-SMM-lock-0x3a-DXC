section .text
global _start
global LockSys
_start:
    call LockSys                ; gọi hàm LockSys
    ret                         ; trả về cho bios
LockSys:
    pushad                      ; Lưu lại trạng thái tất cả thanh ghi
    mov ecx, 0x3A               ; Nạp mã số MSR 0x3a vào ecx
    rdmsr                       ; Đọc giá trị MSR 64 bit vào edx:eax

    test eax, 1                 ; Kiểm tra bit 0
    jnz MsrLock                 ; nếu bit 0 = 1 thì không nhảy 

    or eax, 0x05                ; hoặc bit 0 = 1 , Bit 2 = 1 (Enable VMX)
    wrmsr                       ; ghi giá trị mới vào MSR 0x3A

MsrLock:
                                ; Mã địa chỉ PCI: 0x80000000 | (0 << 16) | (31 << 11) | (0 << 8) | 0xDC
    mov eax, 0x8000F8DC         
    mov dx, 0xCF8               ; nạp mã địa chỉ cổng để đưa dữ liệu qua cổng 0xCF8
    out dx, eax                 ; ghi dữ liệu eax vào thông qua cổng 0xCF8

    mov dx, 0xCFC               ; nạp mã địa chỉ cổng 0xCFC
    in eax, dx                  ; đọc giá trị hiện tại của BIOS_CNTL ra eax

    or eax, 0x22                ; setup bit 1 (khoá quyền đọc)
                                ; và bit 5 (khoá quyền ghi)
    out dx, eax                 ; Ghi ngược lại cổng CFC để khóa phần cứng

    popad                       ; Khôi phục thanh ghi
    ret                         ; trả về hàm locksys
