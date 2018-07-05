# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;

  local _hdfsModuleName = "hdfs";
  local _yarnModuleName = "yarn";
  local _zkModuleName = "zookeeper";
  local _txsqlModuleName = "txsql";
  local _redisModuleName = "redis";
  local _redisModuleVersion = "1.0";
  local _sophonwebModuleName = "sophonweb";
  local _searchModuleName = "elasticsearch";
  local _hyperbaseModuleName = "hyperbase";

  //-------------------
  // Dependent modules
  //-------------------
  local redis = t.createInstance(_redisModuleName, config, _redisModuleVersion) +
    t.moduleResource(_redisModuleName, r.__moduleResourceRaw, config);

  local sophonweb = t.createInstance(_sophonwebModuleName, config, appVersion) +
    t.moduleResource(_sophonwebModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _yarnModuleName,
        name: _yarnModuleName,
      }, {
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }, {
        moduleName: _redisModuleName,
        name: appName  + "-" + _redisModuleName,
      }, {
        moduleName: _searchModuleName,
        name: _searchModuleName,
      }, {
        moduleName: _hyperbaseModuleName,
        name: _hyperbaseModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [redis, sophonweb],
  }
