# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;
  local filerobotVersion = "1.0";

  local _filerobotModuleName = "filerobot";
  local _hdfsModuleName = "hdfs";
  local _txsqlModuleName = "txsql";
  local _pilotModuleName = "pilot";
  local _zkModuleName = "zookeeper";

  //-------------------
  // Dependent modules
  //-------------------

  local filerobot = t.createInstance(_filerobotModuleName, config, filerobotVersion) +
    r.moduleResource(_filerobotModuleName, config);

  local pilot = t.createInstance(_pilotModuleName, config, appVersion) +
    r.moduleResource(_pilotModuleName, config) +
    {
      dependencies: [{
        moduleName: _filerobotModuleName,
        name: appName + "-" + _filerobotModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [filerobot, pilot],
    TCU: {
      [_filerobotModuleName]: r.moduleTCU(_filerobotModuleName, config),
      [_pilotModuleName]: r.moduleTCU(_pilotModuleName, config),
    },
  }
