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

  //-------------------
  // Dependent modules
  //-------------------

  local notification = t.createInstance(_notificationModuleName, config, notificationVersion) +
    r.moduleResource(_notificationModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local rubik = t.createInstance(_rubikModuleName, config, appVersion) +
    r.moduleResource(_rubikModuleName, config) +
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
      }],
    };

  local TCU = {
    [_notificationModuleName]: r.moduleTCU(_notificationModuleName, config),
    [_rubikModuleName]: r.moduleTCU(_rubikModuleName, config),
  };

  t.getDefaultSettings(config) + {
    instance_list: [notification, rubik],
    TCU: TCU,
  }
