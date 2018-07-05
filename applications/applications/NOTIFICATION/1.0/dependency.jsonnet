# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local notificationVersion = "1.0";

  local _notificationModuleName = "notification";
  local _txsqlModuleName = "txsql";

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

  t.getDefaultSettings(config) + {
    instance_list: [notification],
  }
