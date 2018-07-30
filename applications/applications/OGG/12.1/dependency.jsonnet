# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _oggModuleName = "ogg";

  //-------------------
  // Dependent modules
  //-------------------

  local ogg = t.createInstance(_oggModuleName, config, appVersion) +
  t.moduleResource(_oggModuleName, r.__moduleResourceRaw, config) +
    {
    };

  t.getDefaultSettings(config) + {
    instance_list: [ogg],
  }
