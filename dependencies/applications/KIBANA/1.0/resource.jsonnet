# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      kibana:
        if Debug_Request then
          {
            kibana_cpu_limit: 0.2,
            kibana_memory_limit: 1,
            kibana_cpu_request: self.kibana_cpu_limit,
            kibana_memory_request: self.kibana_memory_limit,
          }
        else
          {
            kibana_cpu_limit: t.objectField(config, "kibana_cpu_limit", 1),
            kibana_memory_limit: t.objectField(config, "kibana_memory_limit", 2),
            kibana_cpu_request: t.objectField(config, "kibana_cpu_request", self.kibana_cpu_limit),
            kibana_memory_request: t.objectField(config, "kibana_memory_request", self.kibana_memory_limit),
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
      kibana: [
        "kibana_cpu_limit",
      ],
    };

    local mem_metrics = {
      kibana: [
        "kibana_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
