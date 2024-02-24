# guacamk
Integration Between Checkmk and Apache Guacamole for Monitoring of the Server and Connections


Requiriments
  checkmk 2.2+ (Raw/Enterprise/Cloud)
  jq


First Step


  1 - Apache Guacamole - Authentication
  2 - Apache Guacamole - Retrieve Connection IDs
  3 - Apache Guacamole - Retrieve Connection Details
  4 - Apache Guacamole - Retrieve Connection Details with IP Addresses
  5 - Checkmk - Retrieve hosts
  6 - Checkmk - Create new hosts
  7 - Checkmk - Activate Changes
  8 - Cleanup files



Installation

 gethosts.mk

    Folder Structure

      ./guacamk
      ./guacamk/files
      .guacamk/logs

  
  gcm_connections.mk
  gcm_sync.mk


  cmk_gethosts.cmk - Retrieve Hosts from Checkmk
  cmk_createhosts.cmk - Create new hosts into Checkmk


  
  
cmk_notification_deletehosts.sh - Delete hosts using a notification

  cmkdeletehosts.cmk
  cmk_createhosts.cmk



      ./files/

=================================================
Create a folder called guacamk

Create a file called guacamk.sh








