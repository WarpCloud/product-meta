# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _smartbiModuleName = "smartbi";

  //-------------------
  // Dependent modules
  //-------------------

  local smartbi = t.createInstance(_smartbiModuleName, config, appVersion) +
    t.moduleResource(_smartbiModuleName, r.__moduleResourceRaw, config);


  t.getDefaultSettings(config) + {
    instance_list: [smartbi],
  }
