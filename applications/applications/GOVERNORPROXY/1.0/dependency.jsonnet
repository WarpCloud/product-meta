# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _gpModuleName = "governor-proxy";

  //-------------------
  // Dependent modules
  //-------------------

  local gp = t.createInstance(_gpModuleName, config, appVersion) +
    t.moduleResource(_gpModuleName, r.__moduleResourceRaw, config);
    
  t.getDefaultSettings(config) + {
    instance_list: [gp],
  }
