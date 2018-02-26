# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local metastoreVersion = "1.0";
  local yarnVersion = "1.0";
  local searchVersion = "1.0";

  local use_search = t.trueOrFalse(config.user_config, "use_search");
  local use_hdfs = t.trueOrFalse(config.user_config, "use_hdfs");
  local use_hyperbase = t.trueOrFalse(config.user_config, "use_hyperbase");
  local use_inceptor = t.trueOrFalse(config.user_config, "use_inceptor");
  local use_yarn = t.trueOrFalse(config.user_config, "use_yarn");

  local _searchModuleName = "elasticsearch";
  local _hdfsModuleName = "hdfs";
  local _hyperbaseModuleName = "hyperbase";
  local _inceptorModuleName = "inceptor";
  local _metastoreModuleName = "metastore";
  local _yarnModuleName = "yarn";
  local _zkModuleName = "zookeeper";
  local _terminalModuleName = "terminal";

  local depend_search =
    if use_search then [{
      moduleName: _searchModuleName,
      name: _searchModuleName,
    }] else [];

  local depend_hdfs =
    if use_hdfs then [{
      moduleName: _hdfsModuleName,
      name: _hdfsModuleName,
    }] else [];

  local depend_hyperbase =
    if use_hyperbase then [{
      moduleName: _hyperbaseModuleName,
      name: _hyperbaseModuleName,
    }] else [];

  local depend_inceptor =
    if use_inceptor then [
    {
      moduleName: _inceptorModuleName,
      name: _inceptorModuleName,
    },{
      moduleName: _metastoreModuleName,
      name: _metastoreModuleName,
    }] else [];

  local depend_yarn =
    if use_yarn then [{
      moduleName: _yarnModuleName,
      name: _yarnModuleName,
    }] else [];

  //-------------------
  // Dependent modules
  //-------------------

  local terminal = t.createInstance(_terminalModuleName, config, appVersion) +
    r.moduleResource(_terminalModuleName, config) +
    {
      dependencies:
        depend_search +
        depend_hdfs +
        depend_hyperbase +
        depend_inceptor +
        depend_yarn,
    };

  t.getDefaultSettings(config) + {
    instance_list: [terminal],
    TCU: {
      [_terminalModuleName]: r.moduleTCU(_terminalModuleName, config),
    },
  }
