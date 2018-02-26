# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local notificationVersion = "1.0";

  local _hdfsModuleName = "hdfs";
  local _hyperbaseModuleName = "hyperbase";
  local _kafkaModuleName = "kafka";
  local _notificationModuleName = "notification";
  local _searchModuleName = "elasticsearch";
  local _txsqlModuleName = "txsql";
  local _governorModuleName = "governor";

  //-------------------
  // Dependent modules
  //-------------------

  local notification = t.createInstance(_notificationModuleName, config, notificationVersion) +
    r.moduleResource(_notificationModuleName, config) +
    {
      dependencies: [{
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local governor = t.createInstance(_governorModuleName, config, appVersion) +
    r.moduleResource(_governorModuleName, config) +
    {
      dependencies: [{
        moduleName: _hdfsModuleName,
        name: _hdfsModuleName,
      }, {
        moduleName: _hyperbaseModuleName,
        name: _hyperbaseModuleName,
      }, {
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }, {
        moduleName: _notificationModuleName,
        name: appName + "-" + _notificationModuleName,
      }, {
        moduleName: _searchModuleName,
        name: _searchModuleName,
      }, {
        moduleName: _txsqlModuleName,
        name: _txsqlModuleName,
      }],
    };

  local TCU = {
    [_notificationModuleName]: r.moduleTCU(_notificationModuleName, config),
    [_governorModuleName]: r.moduleTCU(_governorModuleName, config),
  };

  t.getDefaultSettings(config) + {
    instance_list: [notification, governor],
    TCU: TCU,
  }
