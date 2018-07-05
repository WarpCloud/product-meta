# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local notificationVersion = "1.0";

  local _inceptorModuleName = "inceptor";
  local _notificationModuleName = "notification";
  local _txsqlModuleName = "txsql";
  local _rubikModuleName = "rubik";
  local _workflowModuleName = "workflow";

  //-------------------
  // Dependent modules
  //-------------------

  local notification = t.createInstance(_notificationModuleName, config, notificationVersion) +
    t.moduleResource(_notificationModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local rubik = t.createInstance(_rubikModuleName, config, appVersion) +
    t.moduleResource(_rubikModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _inceptorModuleName,
        name: _inceptorModuleName,
      }, {
        moduleName: _notificationModuleName,
        name: appName + "-" + _notificationModuleName,
      },{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }, {
        moduleName: _workflowModuleName,
        name: _workflowModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [notification, rubik],
  }
