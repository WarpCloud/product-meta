# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local notificationVersion = "1.0";

  local _txsqlModuleName = "txsql";
  local _notificationModuleName = "notification";
  local _ticketModuleName = "ticket";

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

  local ticket = t.createInstance(_ticketModuleName, config, appVersion) +
    r.moduleResource(_ticketModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },
      {
        moduleName: _notificationModuleName,
        name: appName + "-" + _notificationModuleName,
      }
      ],
    };

  t.getDefaultSettings(config) + {
    instance_list: [notification, ticket],
    TCU: {
      [_notificationModuleName]: r.moduleTCU(_notificationModuleName, config),
      [_ticketModuleName]: r.moduleTCU(_ticketModuleName, config),
    },
  }
