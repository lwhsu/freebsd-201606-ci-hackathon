class: center, middle

# FreeBSD CI

Li-Wen Hsu &lt; lwhsu@FreeBSD.org &gt;

---
# Agenda

- Curret system architecture, resource we have
- My planned new system architecture
- Current build jobs we have
- Install Jenkins on FreeBSD, basic setup and maintenance
- "Pipeline" job in Jenkins 2
- Jenkins plugins now used in our system, and some useful plugins
- Curent issues
- Current TODO items


- Notes: https://titanpad.com/Oi9TVclLjc (please help!)

---
# System Architecture

https://wiki.freebsd.org/Jenkins/Architecture

- [2016/04](https://wiki.freebsd.org/Jenkins/Architecture?action=AttachFile&do=get&target=jenkins_freebsd_org-now.png)
- 2016/05
  - jenkins10 (VM) moved to chaos.ysv

- Issues
  - Some jobs require package pre-installed on build slaves
      - can be solved by automatically provision build environment (script needed!)
  - Running test VM depends on NFS, adding one more unstable factor
      - can be solved by introducing a artifact server
  - Running test/buil may crash the host where jenkins master is running

---
# Resource we have currently

https://wiki.freebsd.org/Jenkins/MachineList

arthur.nyi (added 2016/04)
- CPU: Intel(R) Xeon(R) CPU E5-2650 v3 @ 2.30GHz (2300.05-MHz K8-class CPU)
- FreeBSD/SMP: Multiprocessor System Detected: 40 CPUs
- ada[0-1]:
  - &lt;INTEL SSDSC2BA200G4 G2010140&gt; ACS-2 ATA SATA 3.x device
  - 190782MB (390721968 512 byte sectors)
- da[0-3]:
  - &lt;ATA HGST HUS726020AL T7J0&gt; Fixed Direct Access SPC-4 SCSI device
  - 1907729MB (3907029168 512 byte sectors)

---
# Planned new system architecture
- main server
  - jenkins master jail
  - web server jail
      - reverse proxy for jenkins
      - serving artifact to external users
  - artifact storage jail
      - running ftpd (ftp-over-tls) for slaves uploading artifact
  - admin jail
      - config repository

---
# Planned new system architecture (c.)
- jail node(s)
  - Simple build, focus on build speed
- bhyve node(s)
  - provision test VM with image built in previous phase
- qemu node(s)
  - run test VM for the arch that bhyve doesn't support


- Cloud nodes?

---
# Planned resource allocation
(while YSV still available)
.left-column[
Hardware allocation
- main server
  - wreck.ysv
- jail node(s)
  - arthur.nyi
- bhyve node(s)
  - chaos.ysv
  - arthur.nyi
- qemu node(s)
  - kyua*.nyi
]
.right-column[
Possible issues
- YSV decommission
- arthur.nyi's storage is too good for a build salve
- arthur.nyi's CPU/memory are too good for a master node


- can we buy new machine in NYI and move/exchange components on arthur.nyi?
]

---
# Planned resource allocation
(after YSV decommission)
- Need IPv4 routing for jenkins connecting to update server
- Need another physical machine for separating external user-facing service and build salves


---
# Current build jobs we have
- pipeline
  - FreBSD_HEAD, FreeBSD_stable-10
- build-in-jail
  - arm64, i386 builds

---
# Install Jenkins on FreeBSD, basic setup and maintenance

- Demo
  - pkg install Jenkins
  - basic securiry setting
  - update plugins

---
# "Pipeline" job in Jenkins 2
- https://jenkins.io/2.0/#pipelines
- Pipelie as code
- Durable


- Demo
  - Hello world
  - Snipper generator

- freebsd-ci
  - https://github.com/freebsd/freebsd-ci/blob/master/scripts/build/build-test.groovy

---
# Jenkins plugins now used in our system, and some useful plugins
- https://wiki.freebsd.org/Jenkins/#Plugins_we_use
- LDAP
- matrix authorization
- green balls
- compiler warnings
- checkstyle
- phabricator differential
  - needs patch for working with SVN

---
# Current issues
- Publish-over-ftp doesn't support pipeline
  - can use multiple jobs (old-style pipeline)
  - working on fixing
      - https://github.com/lwhsu/publish-over-ftp-plugin
  - Use artifact storage built in jenkins
- pipeline script and source code located in different repositories
  - cause SCM monitoring failing
  - move pipeline definition to svn.freebsd.org?
  - (workaround) just create a "monitoring job"

---
# Current TODO items
- Integration with Phabricator (reviews.freebsd.org)
  - https://github.com/uber/phabricator-jenkins-plugin
- Revive clang-scan-build
  - Use `make analyze`
- Automatically exp-run (for all tree / one port)
- job for checking reproducible build (src, ports)
  - sysutils/py-diffoscope
  - PublishHTML plugin
- Integration with redports (make redpots thin, just handing authenication and passing patch)


- Housekeeping the resources requested by jenkins-admin@
  - IPs, firewall rules, etc.
- Stage environment
- Better authenication model
  - OAuth2, needs forking and modification other oauth plugins
      - https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin
      - also needs help from clusteradm, and clusteram needs help
      - other cluster services will also benefite from this

---
# Small TBD items
- new domain name?
  - ci.freebsd.org?
  - build.freebsd.org?
- job naming convention

---
# Propose a new build job
- Install jenkins locally
- Install required plugins (and document: what are they, do they need special Jenkins global settings?)
- Create a job without specify build node / label
- Pass me ${JENKINS_HOME}/jobs/&lt;jobname&gt;/config.xml

---
# More details
https://docs.google.com/document/d/1qI2vH2tWdzifeb-QfQrAEBz5SCe84xXmuhmNjXgtxs4/pub
(published version, no login to google required)


TODO:
- arrange it
- extract TODO items and put on wiki
