# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;
  
  
  local _txsqlModuleName = "txsql";
  local _moduleName = "propeller";

  //-------------------
  // Dependent modules
  //-------------------

  local propeller = t.createInstance(_moduleName, config, appVersion) +
    t.moduleResource(_moduleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [
      {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [propeller],
  }
