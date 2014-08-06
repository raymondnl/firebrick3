# FIREBrick 3
==========

Software for the open source hardware write-blocker/imager.

##### FIREBrick features:
* Autonomous disk imaging at speeds of up to 5Gb per minute (disk dependent)
* iSCSI write blocker function
* Stand-alone version supports storage mirroring and encryption
* Web frontend to control
* Portable – fits in a small HTPC case, including display
* Free, open source firmware
* Can be fully customized to the needs of specific departments
* Automatic RAID storage detection
* Provides a web frontend. The user connects to the FIREBrick via an ethernet cable, the system provides an IP address via DHCP (192.168.253.x). Frontend accessible via a web browser (192.168.253.1).

To build a FIREBrick you need:

* ASRock E350M1 Motherboard
* >= 1Gb DDR3 Desktop RAM (1333 or 1066)


This version of the FIREBrick has the possibility to be extended with extra software, through a USB-stick. A module is a filesystem image which is mounted in to the FIREBrick. Before the module is mounted it is checked if it can be trusted by verifing the md5hash of the image and compare is to the stored hash in the module definition file which is digitally signed.

This build needs a little more work, currently has basic working functionality.

###### For UCD MSc students:
[Jira/Confluence](https://firebrick.atlassian.net/wiki/display/SC/Build+notes)
