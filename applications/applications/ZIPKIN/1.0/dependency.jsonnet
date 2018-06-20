# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local _zipkinVersion = "1.0";

  local _zipkinModuleName = "zipkin";

  //-------------------
  // Dependent modules
  //-------------------

  local zipkin = t.createInstance(_zipkinModuleName, config, _zipkinVersion) +
    r.moduleResource(_zipkinModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [zipkin],
  }
