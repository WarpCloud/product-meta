# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _searchModuleName = "elasticsearch";

  //-------------------
  // Dependent modules
  //-------------------

  local search = t.createInstance(_searchModuleName, config, appVersion) +
    r.moduleResource(_searchModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [search],
    TCU: {
      [_searchModuleName]: r.moduleTCU(_searchModuleName, config),
    },
  }
