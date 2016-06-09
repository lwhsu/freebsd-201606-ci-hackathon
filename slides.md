class: center, middle

# FreeBSD CI

Li-Wen Hsu &lt; lwhsu@FreeBSD.org &gt;

---
# Agenda

- Current system architecture, resource we have
- Planned new system architecture
- Current build jobs we have
- Install Jenkins on FreeBSD, basic setup and maintenance
- "Pipeline" job in Jenkins 2
- Jenkins plugins now used in our system, and some useful plugins
- Current issues
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
      - Can be solved by automatically setup/teardown build environment (script needed!)
  - Running test VM depends on NFS, adding one more unstable factor
      - Can be solved by introducing a artifact server
  - Running test/build may crash the host where jenkins master is running

---
# Resource we have currently

https://wiki.freebsd.org/Jenkins/MachineList

arthur.nyi (arrived 2016/04, under testing)
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
- Main server
  - Jenkins master jail
  - Web server jail
      - Reverse proxy for jenkins
      - Serving artifact to external users
  - Artifact storage jail
      - Running ftpd (ftp-over-tls) for slaves uploading artifact
      - For jobs to get the artifact from upstream jobs, then do further build/testing
  - Admin jail
      - Config repository

---
# Planned new system architecture (c.)
- Slave nodes, categorized by type/usage
  - Jail node(s)
      - Simple build, focus on build speed
  - bhyve node(s)
      - provision test VM with image built in previous phase
  - QEMU node(s)
      - run test VM for the arch that bhyve doesn't support
      - https://wiki.freebsd.org/QemuRecipes
- Slaves connects back to master server
  - Don't use ssh, it's requested by clusteradm
  - https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds#Distributedbuilds-LaunchslaveagentviaJavaWebStart
  - https://github.com/lwhsu/jenkins-slave-scripts
      - Currently running on kyua\*.nyi

---
# Planned new system architecture (misc)
- Outgoing mail relay
  - What should be used in the "From:" field for reporting mails?
  - jenkins-admin@ (currently), jenkins-no-reply@
- Monitoring, for service liveness check
  - May need clusteradm help
- Nodes on cloud?

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
  - havoc.ysv
  - arthur.nyi
- qemu node(s)
  - kyua\*.nyi
]
.right-column[
Possible issues
- YSV decommission (when?)
- arthur.nyi's storage is too good for a build salve
- arthur.nyi's CPU/memory are too good for a master node


- Can we buy new machines in NYI and move/exchange components on arthur.nyi?
]

---
# Planned resource allocation
(after YSV decommission)
- Need IPv4 routing for jenkins connecting to update server
- Need another physical machine for separating external user-facing service and build salves


---
# Current build jobs we have
- Pipeline jobs
  - FreBSD\_HEAD, FreeBSD\_stable-10
- Freestyle jobs
  - doc
- Freestyle jobs, "build-in-jail"
  - arm64, i386 builds

---
# Install Jenkins on FreeBSD, basic setup and maintenance

- Demo
  - pkg install Jenkins
  - basic securiry setting
  - update plugins

- Job configuration tool
  - Jenkins Job Builder — from OpenStack
      - http://docs.openstack.org/infra/jenkins-job-builder/
      - https://www.mediawiki.org/wiki/Continuous_integration/Jenkins_job_builder

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
- https://wiki.freebsd.org/Jenkins/#Plugins_we_use (need update/cleanup)
  - LDAP
  - matrix authorization
  - green balls
  - compiler warnings
  - checkstyle
  - email-ext
  - Embeddable Build Status
  - phabricator differential
      - needs patch to work with SVN
- https://wiki.jenkins-ci.org/display/JENKINS/Plugins

---
# Current issues
- Publish-over-ftp doesn't support pipeline
  - Cannot make pipeline job use artifact server
  - Workaround: using multiple freestyle jobs (old-style pipeline)
  - Working on fixing
      - https://github.com/lwhsu/publish-over-ftp-plugin
  - Use artifact storage built in jenkins
- Pipeline script and source code located in different repositories
  - Cause SCM monitoring failing
  - Move pipeline definition to svn.freebsd.org?
  - Workaround: create a "monitoring job", then set pipeline built after that

---
# Current TODO items
- **Recruit more people to join jenkins-admin@**
- Create new jenkins cluster, move current jobs to it
- More complex pipeline
  - ex: quick amd64/i386 build -&gt; make universe -&gt; test in VM
- Integration with Phabricator (reviews.freebsd.org)
  - https://github.com/uber/phabricator-jenkins-plugin
- A better "template job"
  - preliminary work:
      - https://github.com/freebsd/freebsd-ci/tree/master/scripts/jail
      - https://github.com/freebsd/freebsd-ci/tree/master/jobs/FreeBSD_Doc-igor
      - Have a "FreeBSD jail wrapper plugin"?
          - Fork chroot or docker plugin

---
# Current TODO items (c.)
- Revive clang-scan-build
  - Use `make analyze` & `make checkworld`
  - clang-scan-build plugin
- Automatically exp-run (for all tree / one port)
- job for checking reproducible build (src, ports)
  - sysutils/py-diffoscope
  - PublishHTML plugin
- Integration with redports
  - Make redports thin, just handing authenication and passing patch
- Jobs for nono-default-on tests
  - DTrace test suit

---
# Current TODO items (c.)
- Housekeeping the resources requested by jenkins-admin@
  - IPs, firewall rules, etc.
  - Need help from clusteradm to retrieve list
- Stage environment (ci-dev.freebsd.org)
  - Jail inside jail?
- Better authenication model
  - OAuth2, needs forking and modification other oauth plugins
      - https://wiki.jenkins-ci.org/display/JENKINS/Github+OAuth+Plugin
      - also needs help from clusteradm, and clusteradm needs help
      - other cluster services will also benefite from this
- Better Dashboard
  - https://ci.trafficserver.apache.org/

---
# TBD items
- Pipeline/jobs trigger frequency
  - Building world & kernel takes ~20 mins, full regression test takes ~1 hour
  - A single pipline takes too much time, cannot detect compiling fail quick enough
  - A pipeline configurated running jobs in parallel makes endless regression jobs
      - N "compiling test jobs" trigger 1 "regression test job" ?
      - regression job can only run one in a time, just takes latest result from compiling job
- New domain name?
  - ci.freebsd.org? build.freebsd.org?
- Job naming convention
- Real hardware test
- How to work with re@
  - Official snapshot?
  - Full pre-release tests
      - ABI compatibility check

---
# Propose a new build job
- Install jenkins locally
- Install required plugins
  - Document:
      - What are they?
      - Do they need special Jenkins global settings?
- Create a job you like
- Send ${JENKINS_HOME}/jobs/&lt;jobname&gt;/config.xml


- Use jenkins-job-builder?

---
# More details
https://docs.google.com/document/d/1qI2vH2tWdzifeb-QfQrAEBz5SCe84xXmuhmNjXgtxs4/pub
(published version, no login to google required)


TODO:
- Arrange it
- Extract TODO items and put on wiki
