# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _harborModuleName = "harbor";

  //-------------------
  // Dependent modules
  //-------------------

  local harbor = t.createInstance(_harborModuleName, config, appVersion) +
    t.moduleResource(_harborModuleName, r.__moduleResourceRaw, config);

  t.getDefaultSettings(config) + {
    instance_list: [harbor],
  }
