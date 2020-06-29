#!/usr/bin/python

###############################################################################################
# Description: Configure http access,error logs httptransport.                                #
# Usage: ./wsadmin.sh -lang jython -f configure_HTTP_accessLog.sh <cluster/jvm name> / all    #
#        You can pass <cluster_name>/<jvm name> as argument.                                  #
#        all - will confgure access/error log for all clusters/jvms in a cell                 #
###############################################################################################


import sys
import string
import time

clus_name=sys.argv[0]
task_action=sys.argv[1]

access_log_format='"%{%Y/%m/%d}t %a %{x-forwarded-for}i %{wsg-clientip}i %{Host}i %h %r %s %b %{User-agent}i %{Cookie}i %{JSESSIONID}C %{Referer}i %D"'
#access_log_format='"%{%Y/%m/%d}t %a %{x-forwarded-for}i %{wsg-clientip}i %{Host}i %h %r %s %b %{Location}o %{User-agent}i %{Cookie}i %{jsessionid}C %{Referer}i %D"'
http_accessLog_args='[[filePath ${SERVER_LOG_ROOT}/http_access.log] [maximumBackupFiles 5] [maximumSize 50]]'
http_errorLog_args='[[filePath ${SERVER_LOG_ROOT}/http_error.log] [maximumBackupFiles 5] [maximumSize 50]]'
https_accessLog_args='[[filePath ${SERVER_LOG_ROOT}/https_access.log] [maximumBackupFiles 5] [maximumSize 50]]'
https_errorLog_args='[[filePath ${SERVER_LOG_ROOT}/https_error.log] [maximumBackupFiles 5] [maximumSize 50]]'
accessLogFormatEnable='[[validationExpression ""] [name "accessLogFormat"] [description "mystd"] [value '+access_log_format+'] [required "false"]]'
accessLogFormatDisable='[[validationExpression ""] [name "loggingDisable"] [description "disable chain specific logging"] [value "true"] [required "false"]]'
enableBuildBackupList='[[validationExpression ""] [name "EnableBuildBackupList"] [description "scan for the historical log files and role over with any newer log files created based on the conditions"] [value "true"] [required "false"]]'
sustainedHighVolumeLogging='[[validationExpression ""] [name "SustainedHighVolumeLogging"] [description "allow the logging code to attempt to catch up with the backlog of entries"] [value "true"] [required "false"]]'


def update_accessLog(node_name, jvm_name, tc):
  cell_name=AdminControl.getCell()
  if (tc == 'HTTP_2'):
     accessLog_args=http_accessLog_args
     errorLog_args=http_errorLog_args
  
  if (tc == 'HTTP_4'):
     accessLog_args=https_accessLog_args
     errorLog_args=https_errorLog_args
  
  configID=AdminConfig.getid("/Cell:"+cell_name+"/Node:"+node_name+"/Server:"+jvm_name+"/TransportChannelService:/HTTPInboundChannel:"+tc+"/")
  if (task_action == "enable"):
    print ' -- INFO: enable Logging'
    AdminConfig.modify(configID, '[[enableLogging true] [useChannelAccessLoggingSettings true] [useChannelErrorLoggingSettings true]]')
    AdminConfig.save()
    print ' -- INFO: Done.'
  elif (task_action == "disable"):
    print ' -- INFO: disable Logging'
    AdminConfig.modify(configID, '[[enableLogging false] [useChannelAccessLoggingSettings false] [useChannelErrorLoggingSettings false]]')
    AdminConfig.save()
    print ' -- INFO: Done.'

  HICL_exists=AdminConfig.list('HTTPInboundChannelLogging', configID)
  if len(HICL_exists) == 0:
    if (task_action == "enable"):
       print ' -- INFO: enable HTTP Inbound Channel Logging'
       HICL_C=AdminConfig.create('HTTPInboundChannelLogging', configID, '[[enableErrorLogging true] [enableAccessLogging true]]')
       HICL_configID=AdminConfig.showAttribute(configID, "httpInboundChannelLogging")
       if len(HICL_C) > 0:
         AdminConfig.save()
         print ' -- INFO: Done.'
       else:
         print ' -- ERROR: Script failed at HICL_C'
    elif (task_action == "disable"):
       print ' -- INFO: HTTP Inbound Channel Logging NOT enabled.'
  else:
    if (task_action == "enable"):
      print ' -- INFO: enable HTTP Inbound Channel Logging'
      HICL_configID=AdminConfig.showAttribute(configID, "httpInboundChannelLogging")
      HICL_M=AdminConfig.modify(HICL_configID, '[[enableAccessLogging true] [enableErrorLogging true]]')
      if len(HICL_M) > 0:
        print ' -- ERROR: Script failed at HICL_M'
      else:
        AdminConfig.save()
        print ' -- INFO: Done.'
    elif (task_action == "disable"):
      print ' -- INFO: disable HTTP Inbound Channel Logging'
      HICL_configID=AdminConfig.showAttribute(configID, "httpInboundChannelLogging")
      HICL_M=AdminConfig.modify(HICL_configID, '[[enableAccessLogging false] [enableErrorLogging false]]')
      if len(HICL_M) > 0:
        print ' -- ERROR: Script failed at HICL_M'
      else:
        AdminConfig.save()
        print ' -- INFO: Done.'
     
  if (task_action == "enable"):
    print ' -- INFO: enable accessLog errorLog'
    AL_exists=AdminConfig.list('LogFile', HICL_configID)
    if len(AL_exists) == 0:
      AL_C=AdminConfig.create('LogFile', HICL_configID, accessLog_args, 'accessLog')
      EL_C=AdminConfig.create('LogFile', HICL_configID, errorLog_args, 'errorLog')
      if len(AL_C) > 0:
        AdminConfig.save()
        print ' -- INFO: Done.'
        AL_configID=AdminConfig.showAttribute(HICL_configID, "accessLog")
        EL_configID=AdminConfig.showAttribute(HICL_configID, "errorLog")
      else:
        print ' -- ERROR: Script failed at AL_C'
    else:
      AL_configID=AdminConfig.showAttribute(HICL_configID, "accessLog")
      EL_configID=AdminConfig.showAttribute(HICL_configID, "errorLog")
      AL_M=AdminConfig.modify(AL_configID, accessLog_args)
      EL_M=AdminConfig.modify(EL_configID, errorLog_args)
      if len(AL_M) > 0:
        print ' -- ERROR: Script failed at AL_M'
      else:
        AdminConfig.save()
        print ' -- INFO: Done.'
     
  custom_props=AdminConfig.list('Property', configID)
  for custom_prop in custom_props.split():
    custom_prop_name=AdminConfig.showAttribute(custom_prop, "name")
    if len(custom_prop_name) > 0:
      if (custom_prop_name == "accessLogFormat"):
        print ' -- INFO: ' +tc+ ' Custom Property: accessLogFormat exists ... removing'
        remove_custom_prop=AdminConfig.remove(custom_prop)
        if len(remove_custom_prop) > 0:
          print ' -- ERROR: ' +tc+ ' Custom Property: accessLogFormat ... remove operation FAILED.'
          print ' -- INFO: Please check the error and verify configuration.'
        else:
          AdminConfig.save()
          print ' -- INFO: ' +tc+ ' Custom Property: accessLogFormat ... removed'
      if (custom_prop_name == "loggingDisable"):
        print ' -- INFO: ' +tc+ ' Custom Property: loggingDisable exists ... removing'
        remove_custom_prop=AdminConfig.remove(custom_prop)
        if len(remove_custom_prop) > 0:
          print ' -- ERROR: ' +tc+ ' Custom Property: loggingDisable ... remove operation FAILED.'
          print ' -- INFO: Please check the error and verify configuration.'
        else:
          AdminConfig.save()
          print ' -- INFO: ' +tc+ ' Custom Property: loggingDisable ... removed'
      if (custom_prop_name == "EnableBuildBackupList"):
        print ' -- INFO: ' +tc+ ' Custom Property: EnableBuildBackupList exists ... removing'
        remove_custom_prop=AdminConfig.remove(custom_prop)
        if len(remove_custom_prop) > 0:
          print ' -- ERROR: ' +tc+ ' Custom Property: EnableBuildBackupList ... remove operation FAILED.'
          print ' -- INFO: Please check the error and verify configuration.'
        else:
          AdminConfig.save()
          print ' -- INFO: ' +tc+ ' Custom Property: EnableBuildBackupList ... removed'
      if (custom_prop_name == "SustainedHighVolumeLogging"):
        print ' -- INFO: ' +tc+ ' Custom Property: SustainedHighVolumeLogging exists ... removing'
        remove_custom_prop=AdminConfig.remove(custom_prop)
        if len(remove_custom_prop) > 0:
          print ' -- ERROR: ' +tc+ ' Custom Property: SustainedHighVolumeLogging ... remove operation FAILED.'
          print ' -- INFO: Please check the error and verify configuration.'
        else:
          AdminConfig.save()
          print ' -- INFO: ' +tc+ ' Custom Property: SustainedHighVolumeLogging ... removed'

  if (task_action == "enable"):
    print ' -- INFO: ' +tc+ ' Custom Property: accessLogFormat ... configuring'
    create_custom_prop=AdminConfig.create('Property', configID, accessLogFormatEnable)
    if len(create_custom_prop) > 0:
      AdminConfig.save()
      print ' -- INFO: ' +tc+ ' Custom Property: accessLogFormat ... configured successfully'
    else:
      print ' -- ERROR: ' +tc+ ' Custom Property: accessLogFormat ... configuration FAILED.'
      print ' -- INFO: Please check the error and verify configuration.'

    print ' -- INFO: ' +tc+ ' Custom Property: EnableBuildBackupList ... configuring'
    create_custom_prop=AdminConfig.create('Property', configID, enableBuildBackupList)
    if len(create_custom_prop) > 0:
      AdminConfig.save()
      print ' -- INFO: ' +tc+ ' Custom Property: EnableBuildBackupList ... configured successfully'
    else:
      print ' -- ERROR: ' +tc+ ' Custom Property: EnableBuildBackupList ... configuration FAILED.'
      print ' -- INFO: Please check the error and verify configuration.'

    print ' -- INFO: ' +tc+ ' Custom Property: SustainedHighVolumeLogging ... configuring'
    create_custom_prop=AdminConfig.create('Property', configID, sustainedHighVolumeLogging)
    if len(create_custom_prop) > 0:
      AdminConfig.save()
      print ' -- INFO: ' +tc+ ' Custom Property: SustainedHighVolumeLogging ... configured successfully'
    else:
      print ' -- ERROR: ' +tc+ ' Custom Property: SustainedHighVolumeLogging ... configuration FAILED.'
      print ' -- INFO: Please check the error and verify configuration.'

  if (task_action == "disable"):
    print ' -- INFO: ' +tc+ ' Custom Property: loggingDisable ... configuring'
    create_custom_prop=AdminConfig.create('Property', configID, accessLogFormatDisable)
    if len(create_custom_prop) > 0:
      AdminConfig.save()
      print ' -- INFO: ' +tc+ ' Custom Property: loggingDisable ... configured successfully'
    else:
      print ' -- ERROR: ' +tc+ ' Custom Property: loggingDisable ... configuration FAILED.'
      print ' -- INFO: Please check the error and verify configuration.'

def update_jvm(jvm_name):
  objNameString = AdminControl.completeObjectName('WebSphere:type=Server,name='+jvm_name+',*')
  node_name=AdminControl.getAttributes(objNameString, "nodeName").replace('[','').replace(']','')
  node_name=node_name.split()[1]
  print "\n -- INFO: Updating JVM: " +jvm_name+ " for HTTP_2"
  update_accessLog(node_name, jvm_name, "HTTP_2")
  print "\n -- INFO: Updating JVM: " +jvm_name+ " for HTTP_4"
  update_accessLog(node_name, jvm_name, "HTTP_4")
  #print "\n"

def update_cluster(clus_name):
  cluster_configID=AdminConfig.getid("/ServerCluster:"+clus_name )
  cluster_member_configIDs=AdminConfig.showAttribute(cluster_configID, "members")
  cluster_member_configIDs=cluster_member_configIDs[1:-1]
  for cluster_member_configID in cluster_member_configIDs.split():
     node_name=AdminConfig.showAttribute(cluster_member_configID, "nodeName")
     jvm_name=AdminConfig.showAttribute(cluster_member_configID, "memberName")
     print "\n -- INFO: Updating JVM: " +jvm_name+ " for HTTP_2"
     update_accessLog(node_name, jvm_name, "HTTP_2")
     print "\n -- INFO: Updating JVM: " +jvm_name+ " for HTTP_4"
     update_accessLog(node_name, jvm_name, "HTTP_4")
     #print "\n"

#-----------------------------------------------------------------
# Main
#-----------------------------------------------------------------
if clus_name == "all":
   cell_name=AdminControl.getCell()
   clusters=AdminConfig.list('ServerCluster', AdminConfig.getid( "/Cell:"+cell_name+"/"))
   if not clusters:
     jvms=AdminTask.listServers('[-serverType APPLICATION_SERVER ]')
     if not jvms:
       print "\n -- ERROR: Could not find any Cluster or JVM\n" % clus_name
     else:
       for jvm in jvms.split():
          print "\n"
          jvm_name=AdminConfig.showAttribute(jvm, "name")
          update_jvm(jvm_name)
          print "\n"
   else:
      for cluster in clusters.split('\n'):
         print "\n"
         clus_name=AdminConfig.showAttribute(cluster, "name")
         print " -- INFO: Cluster: " +clus_name
         update_cluster(clus_name)
         print "\n"
else:
   cluster_configID=AdminConfig.getid("/ServerCluster:"+clus_name )
   if not cluster_configID:
     jvm_configID=AdminConfig.getid("/Server:"+clus_name )
     if not jvm_configID:
       print "\n -- ERROR: Cluster or JVM %s does not exist!\n" % clus_name
     else:
       print "\n"
       jvm_name=clus_name
       update_jvm(jvm_name)
       print "\n"
   else:
     print "\n"
     print " -- INFO: Cluster: " +clus_name
     update_cluster(clus_name)
     print "\n"
#-----------------------------------------------------------------
