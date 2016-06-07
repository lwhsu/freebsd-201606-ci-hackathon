class: center, middle

# FreeBSD CI

Li-Wen Hsu &lt; lwhsu@FreeBSD.org &gt;

---
# Agenda

- Curret system architecture, resource we have
- My planned new system architecture
- Current build jobs we have
- Install Jenkins on FreeBSD and basic setup and maintenance
- "Pipeline" job in Jenkins 2
- Jenkins plugins now used in our system, and some useful plugins
- The issues we currently have.
- Current TODO items

---
# System Architecture

[2016/04](https://wiki.freebsd.org/Jenkins/Architecture?action=AttachFile&do=get&target=jenkins_freebsd_org-now.png)

https://wiki.freebsd.org/Jenkins/Architecture

---
# Resource we have currently

https://wiki.freebsd.org/Jenkins/MachineList

arthur.nyi
- CPU: Intel(R) Xeon(R) CPU E5-2650 v3 @ 2.30GHz (2300.05-MHz K8-class CPU)
- FreeBSD/SMP: Multiprocessor System Detected: 40 CPUs
- ada[0-1]:
  - &lt;INTEL SSDSC2BA200G4 G2010140&gt; ACS-2 ATA SATA 3.x device
  - 190782MB (390721968 512 byte sectors)
- da[0-3]:
  - &lt;ATA HGST HUS726020AL T7J0&gt; Fixed Direct Access SPC-4 SCSI device
  - 1907729MB (3907029168 512 byte sectors)
