# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local use_gntenant = t.trueOrFalse(config.user_config, "use_gntenant");
  local use_gntdc = t.trueOrFalse(config.user_config, "use_gn-tdc");

  local _txsqlModuleName = "txsql";
  local _gntenantModuleName = "gn-tenant";
  local _gntdcModuleName = "gn-tdc";
  local _ticketModuleName = "ticket";

  //-------------------
  // Dependent modules
  //-------------------
  local depend_gntenant =
    if use_gntenant then [{
      moduleName: _gntenantModuleName,
      name: _gntenantModuleName,
    }] else [];

  local depend_gntdc =
    if use_gntdc then [{
      moduleName: _gntdcModuleName,
      name: _gntdcModuleName,
    }] else [];

  local ticket = t.createInstance(_ticketModuleName, config, appVersion) +
    t.moduleResource(_ticketModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },
      ] + depend_gntenant + depend_gntdc,
    };

  t.getDefaultSettings(config) + {
    instance_list: [ticket],
  }
