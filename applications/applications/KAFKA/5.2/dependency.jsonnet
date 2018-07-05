# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local kafkaManagerVersion = "1.1";

  local _zkModuleName = "zookeeper";
  local _kafkaManagerModuleName = "kafka-manager";
  local _kafkaModuleName = "kafka";

  //-------------------
  // Dependent modules
  //-------------------
  local kafkaManager = t.createInstance(_kafkaManagerModuleName, config, kafkaManagerVersion) +
    t.moduleResource(_kafkaManagerModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _kafkaModuleName,
        name: appName + "-" +_kafkaModuleName,
      },
      {
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }],
    };

  local kafka = t.createInstance(_kafkaModuleName, config, appVersion) +
    t.moduleResource(_kafkaModuleName, r.__moduleResourceRaw, config) +
    {
      dependencies: [{
        moduleName: _zkModuleName,
        name: _zkModuleName,
      }],
    };

  t.getDefaultSettings(config) + {
    instance_list: [kafka, kafkaManager],
  }
