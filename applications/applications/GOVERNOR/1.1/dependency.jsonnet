# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local notificationVersion = "1.1";

  local _hdfsModuleName = "hdfs";
  local _hyperbaseModuleName = "hyperbase";
  local _kafkaModuleName = "kafka";
  local _notificationModuleName = "notification";
  local _searchModuleName = "elasticsearch";
  local _txsqlModuleName = "txsql";
  local _governorModuleName = "governor";


  local data_share = t.trueOrFalse(config.user_config, "data_share");

  //-------------------
  // Dependent modules
  //-------------------

  local notification = t.createInstance(_notificationModuleName, config, notificationVersion) +
    t.moduleResource(_notificationModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  
  local extra_dep =
    if data_share then
    [] else [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _hyperbaseModuleName,
        name: _hyperbaseModuleName,
      }, {
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }, {
        moduleName: _searchModuleName,
        name: _searchModuleName,
      }];
  
  local governor = t.createInstance(_governorModuleName, config, appVersion) +
     t.moduleResource(_governorModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _notificationModuleName,
        name: appName + "-" + _notificationModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }] + extra_dep,
    };
    
  t.getDefaultSettings(config) + {
    instance_list: [notification, governor],
  }
