# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _simmailModuleName = "simmail";

  //-------------------
  // Dependent modules
  //-------------------

  local simmail = t.createInstance(_simmailModuleName, config, appVersion) +
    r.moduleResource(_simmailModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [simmail],
    TCU: {
      [_simmailModuleName]: r.moduleTCU(_simmailModuleName, config),
    },
  }
