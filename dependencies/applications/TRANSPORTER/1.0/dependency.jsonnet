# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local _hdfsModuleName = "hdfs";
  local _inceptorModuleName = "inceptor";
  local _txsqlModuleName = "txsql";
  local _transporterModuleName = "tdt";

  //-------------------
  // Dependent modules
  //-------------------

  local transporter = t.createInstance(_transporterModuleName, config, appVersion) +
  r.moduleResource(_transporterModuleName, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _inceptorModuleName,
        name: _inceptorModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [transporter],
    TCU: {
      [_transporterModuleName]: r.moduleTCU(_transporterModuleName, config),
    },
  }
