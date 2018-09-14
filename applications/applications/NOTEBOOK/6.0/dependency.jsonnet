# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local localcranVersion = "6.0";

  local _hdfsModuleName = "hdfs";
  local _yarnModuleName = "yarn";
  local _localcranModuleName = "localcran";
  local _notebookModuleName = "notebook";

  //-------------------
  // Dependent modules
  //-------------------

  local localcran = t.createInstance(_localcranModuleName, config, localcranVersion) +
    t.moduleResource(_localcranModuleName, r.__moduleResourceRaw, config);

  local notebook = t.createInstance(_notebookModuleName, config, appVersion) +
    t.moduleResource(_notebookModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _yarnModuleName,
        name: _yarnModuleName,
      }, {
        moduleName: _localcranModuleName,
        name: appName + "-" +  _localcranModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [notebook, localcran],
  }
