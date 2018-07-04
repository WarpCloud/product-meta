# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;
  local filerobotVersion = "1.2";

  local _filerobotModuleName = "filerobot";
  local _hdfsModuleName = "hdfs";
  local _txsqlModuleName = "txsql";
  local _pilotModuleName = "pilot";
  local _zkModuleName = "zookeeper";
  local _inceptorModuleName = "inceptor";

  local use_inceptor = t.trueOrFalse(config.user_config, "use_inceptor");

  local depend_inceptor =
    if use_inceptor then [{
      moduleName: _inceptorModuleName,
      name: _inceptorModuleName,
    }] else [];

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
      }, {
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }] + depend_inceptor,
    };

  t.getDefaultSettings(config) + {
    instance_list: [filerobot, pilot],
  }
