# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _gitlabModuleName = "gitlab";

  //-------------------
  // Dependent modules
  //-------------------

  local gitlab = t.createInstance(_gitlabModuleName, config, appVersion) +
    t.moduleResource(_gitlabModuleName, r.__moduleResourceRaw, config);

  t.getDefaultSettings(config) + {
    instance_list: [gitlab],
  }
