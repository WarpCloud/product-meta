# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local use_gntenant = t.trueOrFalse(config.user_config, "use_gntenant");

  local _txsqlModuleName = "txsql";
  local _ockleModuleName = "ockle";
  local _tccModuleName = "tcc";
  local _ticketModuleName = "ticket";
  local _simmailModuleName = "simmail";
  local _guardianModuleName = "guardian-cas";
  local _kongModuleName = "kong";
  local _gntenantModuleName = "gn-tenant";

  //-------------------
  // Dependent modules
  //-------------------
  local depend_gntenant =
    if use_gntenant then [{
      moduleName: _gntenantModuleName,
      name: _gntenantModuleName,
    }] else [];

  local tcc = t.createInstance(_tccModuleName, config, appVersion) +
    t.moduleResource(_tccModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },{
        moduleName: _ticketModuleName,
        name: _ticketModuleName,
      },{
        moduleName: _guardianModuleName,
        name: _guardianModuleName,
      }] + depend_gntenant,
    };

  t.getDefaultSettings(config) + {
    instance_list: [tcc],
  }
