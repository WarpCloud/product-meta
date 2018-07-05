# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local zkVersion = "5.2";

  local _zkModuleName = "zookeeper";

  //-------------------
  // Dependent modules
  //-------------------

  local zookeeper = t.createInstance(_zkModuleName, config, zkVersion) +
    t.moduleResource(_zkModuleName, r.__moduleResourceRaw, config);

  t.getDefaultSettings(config) + {
    instance_list: [zookeeper],
  }
