# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";
  local _ockleModuleName = "ockle";
  local _tccModuleName = "tcc";
  local _ticketModuleName = "ticket";
  local _simmailModuleName = "simmail";
  local _guardianModuleName = "guardian";
  local _kongModuleName = "kong";
  local _casModuleName = "cas";

  //-------------------
  // Dependent modules
  //-------------------

  local tcc = t.createInstance(_tccModuleName, config, appVersion) +
    r.moduleResource(_tccModuleName, config) +
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
      },{
        moduleName: _casModuleName,
        name: _casModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [tcc],
    TCU: {
      [_tccModuleName]: r.moduleTCU(_tccModuleName, config),
    },
  }
