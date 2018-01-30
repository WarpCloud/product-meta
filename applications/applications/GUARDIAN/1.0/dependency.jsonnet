# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _guardianModuleName = "guardian";

  //-------------------
  // Dependent modules
  //-------------------

  local guardian = t.createInstance(_guardianModuleName, config, appVersion) +
    r.moduleResource(_guardianModuleName, config);

  local TCU = {
    [_guardianModuleName]: r.moduleTCU(_guardianModuleName, config),
  };

  t.getDefaultSettings(config) + {
    instance_list: [guardian],
    TCU: TCU,
  }
