# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _zkModuleName = "zookeeper";
  local _txsqlModuleName = "txsql";
  local _workflowModuleName = "workflow";

  //-------------------
  // Dependent modules
  //-------------------

  local workflow = t.createInstance(_workflowModuleName, config, appVersion) +
    r.moduleResource(_workflowModuleName, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [workflow],
    TCU: {
      [_workflowModuleName]: r.moduleTCU(_workflowModuleName, config),
    },
  }
