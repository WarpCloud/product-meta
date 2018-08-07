# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _jenkinsModuleName = "qa-jenkins";

  //-------------------
  // Dependent modules
  //-------------------

  local jenkins = t.createInstance(_jenkinsModuleName, config, appVersion) +
    t.moduleResource(_jenkinsModuleName, r.__moduleResourceRaw, config);

  t.getDefaultSettings(config) + {
    instance_list: [jenkins],
  }
