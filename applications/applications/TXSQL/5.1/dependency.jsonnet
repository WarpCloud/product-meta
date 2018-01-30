# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _txsqlModuleName = "txsql";

  //-------------------
  // Dependent modules
  //-------------------

  local txsql = t.createInstance(_txsqlModuleName, config, appVersion) +
    r.moduleResource(_txsqlModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [txsql],
    TCU: {
      [_txsqlModuleName]: r.moduleTCU(_txsqlModuleName, config),
    },
  }
