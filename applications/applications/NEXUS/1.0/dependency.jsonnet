# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _nexusModuleName = "qa-nexus";

  //-------------------
  // Dependent modules
  //-------------------

  local qa_nexus = t.createInstance(_nexusModuleName, config, appVersion) +
    t.moduleResource(_nexusModuleName, r.__moduleResourceRaw, config);

  t.getDefaultSettings(config) + {
    instance_list: [qa_nexus],
  }
