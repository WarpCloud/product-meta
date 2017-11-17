# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      pilot:
        if Debug_Request then
          {
            pilot_cpu_limit: 0.5,
            pilot_memory_limit: 1,
            pilot_cpu_request: self.pilot_cpu_limit,
            pilot_memory_request: self.pilot_memory_limit,
          }
        else
          {
            pilot_cpu_limit: t.objectField(config, "pilot_cpu_limit", 1),
            pilot_memory_limit: t.objectField(config, "pilot_memory_limit", 4),
            pilot_cpu_request: t.objectField(config, "pilot_cpu_request", self.pilot_cpu_limit),
            pilot_memory_request: t.objectField(config, "pilot_memory_request", self.pilot_memory_limit),
          },
      filerobot:
        if Debug_Request then
          {
            filerobot_cpu_limit: 0.5,
            filerobot_memory_limit: 2,
            filerobot_cpu_request: self.filerobot_cpu_limit,
            filerobot_memory_request: self.filerobot_memory_limit,
          }
        else
          {
            local cpu_limit = resource.pilot.pilot_cpu_limit,
            local memory_limit = resource.pilot.pilot_memory_limit,

            filerobot_cpu_limit: t.objectField(config, "filerobot_cpu_limit", cpu_limit),
            filerobot_memory_limit: t.objectField(config, "filerobot_memory_limit", memory_limit),
            filerobot_cpu_request: t.objectField(config, "filerobot_cpu_request", self.filerobot_cpu_limit),
            filerobot_memory_request: t.objectField(config, "filerobot_memory_request", self.filerobot_memory_limit),
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
      pilot: [
        "pilot_cpu_limit",
      ],
      filerobot: [
        "filerobot_cpu_limit",
      ],
    };

    local mem_metrics = {
      pilot: [
        "pilot_memory_limit",
      ],
      filerobot: [
        "filerobot_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
