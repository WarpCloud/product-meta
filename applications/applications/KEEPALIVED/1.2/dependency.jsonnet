# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _keepalivedModuleName = "keepalived";


  //-------------------
  // Dependent modules
  //-------------------

  local keepalived = t.createInstance(_keepalivedModuleName, config, appVersion) +
  t.moduleResource(_keepalivedModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: "kong",
        name: "kong",
      }]
    };

  t.getDefaultSettings(config) + {
    instance_list: [keepalived],
  }
