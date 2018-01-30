# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _redisModuleName = "redis";

  //-------------------
  // Dependent modules
  //-------------------

  local redis = t.createInstance(_redisModuleName, config, appVersion) +
    r.moduleResource(_redisModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [redis],
    TCU: {
      [_redisModuleName]: r.moduleTCU(_redisModuleName, config),
    },
  }
