# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _hdfsModuleName = "hdfs";
  local _txsqlModuleName = "txsql";
  local _transporterModuleName = "tdt";
  local _oggModuleName = "ogg";

  //-------------------
  // Dependent modules
  //-------------------

  local ogg = t.createInstance(_oggModuleName, config, appVersion) +
  t.moduleResource(_oggModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _transporterModuleName,
        name: _transporterModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [ogg],
  }
