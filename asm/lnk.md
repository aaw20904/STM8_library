[Multithreads in MCU](https://www.elesoftrom.com.pl/en/os/multithreaded_programming.pdf)
to fix the error in STVD “STVD Connection error (usb://usb): gdi-error 40201: can’t access configuration database” please run the following commands
Regsvr32 /u "C:\Program Files (x86)\Common Files\Microsoft Shared\DAO\DAO350.DLL"
Regsvr32  "C:\Program Files (x86)\Common Files\Microsoft Shared\DAO\DAO350.DLL"
