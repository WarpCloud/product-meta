# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      kong:
        if Debug_Request then
          {
            kong_cpu_limit: 0.1,
            kong_memory_limit: 1,
            kong_cpu_request: self.kong_cpu_limit,
            kong_memory_request: self.kong_memory_limit,
          }
        else
          {
            kong_cpu_limit: t.objectField(config, "kong_cpu_limit", 1),
            kong_memory_limit: t.objectField(config, "kong_memory_limit", 1),
            kong_cpu_request: t.objectField(config, "kong_cpu_request", self.kong_cpu_limit),
            kong_memory_request: t.objectField(config, "kong_memory_request", self.kong_memory_limit),
          },
      "kong-dashboard":
        if Debug_Request then
          {
            kong_dashboard_cpu_limit: 0.1,
            kong_dashboard_memory_limit: 1,
            kong_dashboard_cpu_request: self.kong_dashboard_cpu_limit,
            kong_dashboard_memory_request: self.kong_dashboard_memory_limit,
          }
        else
          {
            kong_dashboard_cpu_limit: t.objectField(config, "kong_dashboard_cpu_limit", 1),
            kong_dashboard_memory_limit: t.objectField(config, "kong_dashboard_memory_limit", 1),
            kong_dashboard_cpu_request: t.objectField(config, "kong_dashboard_cpu_request", self.kong_dashboard_cpu_limit),
            kong_dashboard_memory_request: t.objectField(config, "kong_dashboard_memory_request", self.kong_dashboard_memory_limit),
          },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

  /*
   * Get resurce configs for each module
   */
  moduleResource(moduleName, config={})::
    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    local module = $.__moduleResourceRaw(moduleName, unifiedConfig);
    {
      configs: module.resource + module.storage,
    },

  /*
   * Define TCU calculation for each module
   */
  moduleTCU(moduleName, config={})::
    local cpu_metrics = {
      kong: [
        "kong_cpu_limit",
      ],
      "kong-dashboard": [
        "kong_dashboard_cpu_limit"
      ],
    };

    local mem_metrics = {
      kong: [
        "kong_memory_limit",
      ],
      "kong-dashboard": [
        "kong_dashboard_memory_limit"
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
