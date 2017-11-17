# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";
  local _notificationModuleName = "notification";
  local _ticketModuleName = "ticket";

  local use_notification = t.trueOrFalse(config.user_config, "use_notification");
  local depend_notification =
    if use_notification then [{
      moduleName: _notificationModuleName,
      name: _notificationModuleName,
    }] else [];

  //-------------------
  // Dependent modules
  //-------------------

  local ticket = t.createInstance(_ticketModuleName, config, appVersion) +
    r.moduleResource(_ticketModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }] + depend_notification,
    };

  t.getDefaultSettings(config) + {
    instance_list: [ticket],
    TCU: {
      [_ticketModuleName]: r.moduleTCU(_ticketModuleName, config),
    },
  }
