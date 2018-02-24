# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;

  local metastoreVersion = "5.1";

  local _hdfsModuleName = "hdfs";
  local _yarnModuleName = "yarn";
  local _zkModuleName = "zookeeper";
  local _slipstreamModuleName = "slipstream";
  local _metastoreModuleName = "metastore";

  //-------------------
  // Dependent modules
  //-------------------

  // Currently metastore depends on MySQL and switches to TxSQL in future version. (2017.08.30)
  local metastore = t.createInstance(_metastoreModuleName, config, metastoreVersion) +
    r.moduleResource(_metastoreModuleName, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }],
    };

  local slipstream = t.createInstance(_slipstreamModuleName, config, appVersion) +
    r.moduleResource(_slipstreamModuleName, config) +
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
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [metastore, slipstream],
  }
