# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _ogg_for_big_dataModuleName = "ogg-for-big-data";

  //-------------------
  // Dependent modules
  //-------------------

  local ogg_for_big_data = t.createInstance(_ogg_for_big_dataModuleName, config, appVersion) +
  t.moduleResource(_ogg_for_big_dataModuleName, r.__moduleResourceRaw, config) +
    {
    };

  t.getDefaultSettings(config) + {
    instance_list: [ogg_for_big_data],
  }
