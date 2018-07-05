# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local use_transporter = t.trueOrFalse(config.user_config, "use_transporter");

  local _zkModuleName = "zookeeper";
  local _txsqlModuleName = "txsql";
  local _transporterModuleName = "tdt";
  local _workflowModuleName = "workflow";

  //-------------------
  // Dependent modules
  //-------------------

  local depend_transporter =
    if use_transporter then [{
      moduleName: _transporterModuleName,
      name: _transporterModuleName,
    }] else [];

  local workflow = t.createInstance(_workflowModuleName, config, appVersion) +
    t.moduleResource(_workflowModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }] + depend_transporter,
    };

  t.getDefaultSettings(config) + {
    instance_list: [workflow],
  }
