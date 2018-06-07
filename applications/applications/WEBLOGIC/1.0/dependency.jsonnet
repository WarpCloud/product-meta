# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _weblogicModuleName = "weblogic";

  //-------------------
  // Dependent modules
  //-------------------

  local weblogic = t.createInstance(_weblogicModuleName, config, appVersion) +
    r.moduleResource(_weblogicModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [weblogic],
  }
