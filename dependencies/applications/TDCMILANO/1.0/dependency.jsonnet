# Copyright 2016 Transwarp Inc. All rights reserved.
# Milano components for TDC deployment.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;

  local appVersion = config.application_version;
  local filebeatVersion = "1.0";
  local logstashVersion = "1.0";
  local milanoPortalVersion = "1.0";
  local zkVersion = "5.0";
  local kafkaVersion = "5.0";

  local _kafkaModuleName = "kafka";
  local _filebeatModuleName = "filebeat";
  local _logstashModuleName = "logstash";
  local _searchModuleName = "elasticsearch";
  local _milanoPortalModuleName = "milano-portal";

  //-------------------
  // Dependent modules
  //-------------------

  local filebeat = t.createInstance(_filebeatModuleName, config, filebeatVersion) +
    r.moduleResource(_filebeatModuleName, config) +
    {
      dependencies: [{
        moduleName: _kafkaModuleName,
        name: _kafkaModuleName,
      }],
    };

  local logstash = t.createInstance(_logstashModuleName, config, logstashVersion) +
    r.moduleResource(_logstashModuleName, config) +
    {
      dependencies: [{
        moduleName: _kafkaModuleName,
        name:  _kafkaModuleName,
      },
      {
        moduleName: _searchModuleName,
        name: _searchModuleName,
      }],
    };

  local milanoPortal = t.createInstance(_milanoPortalModuleName, config, milanoPortalVersion) +
    r.moduleResource(_milanoPortalModuleName, config);

  t.getDefaultSettings(config) + {
    instance_list: [filebeat, logstash, milanoPortal],
    TCU: {
      [_filebeatModuleName]: r.moduleTCU(_filebeatModuleName, config),
      [_logstashModuleName]: r.moduleTCU(_logstashModuleName, config),
      [_milanoPortalModuleName]: r.moduleTCU(_milanoPortalModuleName, config),
    },
  }
