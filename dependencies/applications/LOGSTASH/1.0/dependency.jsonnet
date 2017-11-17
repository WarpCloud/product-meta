# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";
local r = import "resource.jsonnet";

function(config={})
  local appName = config.application_name;
  local appVersion = config.application_version;
  local use_search = t.trueOrFalse(config.user_config, "use_search");

  local _searchModuleName = "elasticsearch";
  local _logstashModuleName = "logstash";

  local depend_search =
    if use_search then [{
      moduleName: _searchModuleName,
      name: _searchModuleName,
    }] else [];

  //-------------------
  // Dependent modules
  //-------------------

  local logstash = t.createInstance(_logstashModuleName, config, appVersion) +
    r.moduleResource(_logstashModuleName, config) +
    {
      dependencies: depend_search,
    };

  t.getDefaultSettings(config) + {
    instance_list: [logstash],
    TCU: {
      [_logstashModuleName]: r.moduleTCU(_logstashModuleName, config),
    },
  }
