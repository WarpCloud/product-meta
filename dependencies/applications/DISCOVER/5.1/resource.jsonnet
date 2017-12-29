# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      discover:
        if Debug_Request then
          {
            discover_cpu_limit: 0.1,
            discover_memory_limit: 4,
            discover_cpu_request: self.discover_cpu_limit,
            discover_memory_request: self.discover_memory_limit,
          }
        else
          {
            discover_cpu_limit: t.objectField(config, "discover_cpu_limit", 4),
            discover_memory_limit: t.objectField(config, "discover_memory_limit", 8),
            discover_cpu_request: t.objectField(config, "discover_cpu_request", self.discover_cpu_limit),
            discover_memory_request: t.objectField(config, "discover_memory_request", self.discover_memory_limit),
          },
      localcran:
        if Debug_Request then
          {
            localcran_cpu_limit: 0.1,
            localcran_memory_limit: 1,
            localcran_cpu_request: self.localcran_cpu_limit,
            localcran_memory_request: self.localcran_memory_limit,
          }
        else
          {
            local cpu_limit = resource.discover.discover_cpu_limit,
            local memory_limit = resource.discover.discover_memory_limit,

            localcran_cpu_limit: t.objectField(config, "localcran_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
            localcran_memory_limit: t.objectField(config, "localcran_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
            localcran_cpu_request: t.objectField(config, "localcran_cpu_request", self.localcran_cpu_limit),
            localcran_memory_request: t.objectField(config, "localcran_memory_request", self.localcran_memory_limit),
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
      discover: [
        "discover_cpu_limit",
      ],
      localcran: [
        "localcran_cpu_limit",
      ],
    };

    local mem_metrics = {
      discover: [
        "discover_memory_limit",
      ],
      localcran: [
        "localcran_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
