# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _despatcherModuleName = "despatcher";
  local _guardianModuleName = "guardian";
  local _txsqlModuleName = "txsql";
  local _gnModuleName = "gn-tdc";
  local _ockleModuleName = "ockle";
  local _workflowModuleName = "workflow";

  //-------------------
  // Dependent modules
  //-------------------

  local despatcher = t.createInstance(_despatcherModuleName, config, appVersion) +
    r.moduleResource(_despatcherModuleName, config) +
    {
      dependencies: [{
        moduleName: _guardianModuleName,
        name: _guardianModuleName,
      },
      {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      },
      {
        moduleName: _gnModuleName,
        name: _gnModuleName,
      },
      {
        moduleName: _ockleModuleName,
        name: _ockleModuleName,
      },
      {
        moduleName: _workflowModuleName,
        name: _workflowModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [despatcher],
  }
