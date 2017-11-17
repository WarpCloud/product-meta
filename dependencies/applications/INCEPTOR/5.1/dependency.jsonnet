# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local metastoreVersion = "5.1";

  local use_hyperbase = t.trueOrFalse(config.user_config, "use_hyperbase");
  local use_search = t.trueOrFalse(config.user_config, "use_search");

  local _zkModuleName = "zookeeper";
  local _hdfsModuleName = "hdfs";
  local _metastoreModuleName = "metastore";
  local _txsqlModuleName = "txsql";
  local _inceptorModuleName = "inceptor";
  local _hyperbaseModuleName = "hyperbase";
  local _searchModuleName = "elasticsearch";

  local depend_hyperbase =
    if use_hyperbase then [{
      moduleName: _hyperbaseModuleName,
      name: _hyperbaseModuleName,
    }] else [];

  local depend_search =
    if use_search then [{
      moduleName: _searchModuleName,
      name: _searchModuleName,
    }] else [];

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

  local inceptor = t.createInstance(_inceptorModuleName, config, appVersion) +
    r.moduleResource(_inceptorModuleName, config) +
    {
      dependencies: [{
        moduleName: _metastoreModuleName,
        name: appName + "-" +  _metastoreModuleName,
      }, {
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }] + depend_hyperbase + depend_search,
    };

  local TCU = {
    [_metastoreModuleName]: r.moduleTCU(_metastoreModuleName, config),
    [_inceptorModuleName]: r.moduleTCU(_inceptorModuleName, config),
  };

  t.getDefaultSettings(config) + {
    instance_list: [metastore, inceptor],
    TCU: TCU,
  }
