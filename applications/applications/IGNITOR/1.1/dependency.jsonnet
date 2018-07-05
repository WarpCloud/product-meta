# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";
  local _ockleModuleName = "ockle";
  local _ignitorModuleName = "ignitor";
  local _simmailModuleName = "simmail";
  local _wormholeModuleName = "wormhole";

  local use_wormhole = t.trueOrFalse(config.user_config, "use_wormhole");
  local depend_wormhole =
    if use_wormhole then [{
      moduleName: _wormholeModuleName,
      name: _wormholeModuleName,
    }] else [];

  //-------------------
  // Dependent modules
  //-------------------

  local ignitor = t.createInstance(_ignitorModuleName, config, appVersion) +
    t.moduleResource(_ignitorModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },{
        moduleName: _ockleModuleName,
        name: _ockleModuleName,
      },{
        moduleName: _simmailModuleName,
        name: _simmailModuleName,
      }] + depend_wormhole,
    };

  t.getDefaultSettings(config) + {
    instance_list: [ignitor],
  }
