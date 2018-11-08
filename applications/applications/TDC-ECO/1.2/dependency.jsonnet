# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _ecoModuleName = "tdc-eco";
  local _txsqlModuleName = "txsql";
  local _guardianModuleName = "guardian-cas";
  local _ockleModuleName = "ockle";
  local _ignitorModuleName = "ignitor";
  local _ticketModuleName = "ticket";
  local _despatcherModuleName = "despatcher";
  local _searchModuleName = "elasticsearch";
  local _dioclesModuleName = "diocles";

  //-------------------
  // Dependent modules
  //-------------------

  local eco = t.createInstance(_ecoModuleName, config, appVersion) +
    t.moduleResource(_ecoModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },{
        moduleName: _guardianModuleName,
        name: _guardianModuleName,
      },{
        moduleName: _ockleModuleName,
        name: _ockleModuleName,
      },{
        moduleName: _ignitorModuleName,
        name: _ignitorModuleName,
      },{
        moduleName: _ticketModuleName,
        name: _ticketModuleName,
      },{
        moduleName: _searchModuleName,
        name: _searchModuleName,
      },{
        moduleName: _dioclesModuleName,
        name: _dioclesModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [eco],
  }

