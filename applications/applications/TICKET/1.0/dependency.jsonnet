# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";
  local _ticketModuleName = "ticket";

  //-------------------
  // Dependent modules
  //-------------------
  local ticket = t.createInstance(_ticketModuleName, config, appVersion) +
    t.moduleResource(_ticketModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [ticket],
  }
