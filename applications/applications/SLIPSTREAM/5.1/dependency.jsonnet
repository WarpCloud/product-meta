# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local metastoreVersion = "5.1";

  local use_hyperbase = t.trueOrFalse(config.user_config, "use_hyperbase");

  local _hdfsModuleName = "hdfs";
  local _yarnModuleName = "yarn";
  local _zkModuleName = "zookeeper";
  local _slipstreamModuleName = "slipstream";
  local _metastoreModuleName = "metastore";
  local _hyperbaseModuleName = "hyperbase";

  local depend_hyperbase =
    if use_hyperbase then [{
      moduleName: _hyperbaseModuleName,
      name: _hyperbaseModuleName,
    }] else [];

  //-------------------
  // Dependent modules
  //-------------------

  // Currently metastore depends on MySQL and switches to TxSQL in future version. (2017.08.30)
  local metastore = t.createInstance(_metastoreModuleName, config, metastoreVersion) +
    t.moduleResource(_metastoreModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }],
    };

  local slipstream = t.createInstance(_slipstreamModuleName, config, appVersion) +
    t.moduleResource(_slipstreamModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _metastoreModuleName,
        name: appName + "-" +  _metastoreModuleName,
      }, {
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _yarnModuleName,
        name: _yarnModuleName,
      }, {
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }] + depend_hyperbase,
    };

  t.getDefaultSettings(config) + {
    instance_list: [metastore, slipstream],
  }
