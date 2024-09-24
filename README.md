![logo-removebg-preview](https://github.com/user-attachments/assets/cb5e882f-c212-4d60-946b-d029f1d72ad1)


# CatBinaries

<div align="left">
    
  [![License: GPL-2.0](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](https://opensource.org/licenses/GPL-2.0)
  <img src="https://img.shields.io/badge/Language%20-Shell Script-darkgreen.svg" style="max-width: 100%;">
  <img src="https://img.shields.io/badge/Tool%20-Privilege escalation-brown.svg" style="max-width: 100%;">
  <img src="https://img.shields.io/badge/Target OS%20-Linux-yellow.svg" style="max-width: 100%;">
  <img src="https://img.shields.io/badge/%20-Linux Security-beige.svg" style="max-width: 100%;">
  <img src="https://img.shields.io/badge/CTFs tools%20-teste?style=flat" style="max-width: 100%;">  

</div>

**This project is strongly inspired by the GTFO bins project. Built for lazy hackers (like me) who prefer to do everything in one place**

Tool to make privilege escalation on linux systems easier, using GTFObins (get the f*** out Binaries) techniques. The tool is designed to exploit, identify and list all binaries deconfigured for privilege exploitation: Binaries with SUID, Capabilities, SUDO privileges, reading privileged files. 

> GTFOBins is a community-driven project that aims to collect Unix binaries that can be abused for privilege escalation. Each entry in the GTFOBins database provides detailed information about a specific binary, including its functionality, potential vulnerabilities, and instructions on how to exploit it to gain escalated privileges. The database serves as a valuable resource for security researchers and system administrators.

## Upload directly to the target machine:
```bash
curl https://raw.githubusercontent.com/Jsmoreira02/CatBinaries/refs/heads/main/CatBinaries.sh -o /tmp/CatBinaries.sh
```

## Identify Vulnerable Binaries:
  ![Gravaratela_20240815_195946online-video-cutter com-ezgif com-video-to-gif-converter](https://github.com/user-attachments/assets/8f154db1-bf71-44d0-8469-361c36697d86)

## Exploit Methods:
 - **SUID**: If the binary has the SUID bit set, it can be exploited to give the highest privilege on Linux/Unix

- **Sudo Binaries**: If the binary is allowed to run as superuser by sudo, it can be exploited to give the highest privilege on Linux/Unix

- **Capabilities**: Exploit CAP_SETUID capability

- **File Read**: It reads data from files, it may be used to do privileged reads

--------------------------------

![Captura de imagem_20240815_202247](https://github.com/user-attachments/assets/45e90ab7-1c7d-42e7-b555-2d0099db3a0a)

--------------------------------

- This script will constantly receive new binaries and forms of exploitation

## Check out the source of inspiration

  - [GTFOBins Page](https://gtfobins.github.io/)
  - [@GTFOBins](https://github.com/GTFOBins)


# Warning:    
> I am not responsible for any illegal use or damage caused by this tool. It was written for fun, not evil and is intended to raise awareness about cybersecurity.

