# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local zkVersion = "5.1";

  local _zkModuleName = "zookeeper";
  local _codisModuleName = "codis";

  //-------------------
  // Dependent modules
  //-------------------
  local codis = t.createInstance(_codisModuleName, config, appVersion) +
    r.moduleResource(_codisModuleName, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [codis],
  }
