# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      ticket:
        if Debug_Request then
          {
            ticket_cpu_limit: 0.5,
            ticket_memory_limit: 1,
            ticket_cpu_request: self.ticket_cpu_limit,
            ticket_memory_request: self.ticket_memory_limit,
          }
        else
          {
            ticket_cpu_limit: t.objectField(config, "ticket_cpu_limit", 1),
            ticket_memory_limit: t.objectField(config, "ticket_memory_limit", 4),
            ticket_cpu_request: t.objectField(config, "ticket_cpu_request", self.ticket_cpu_limit),
            ticket_memory_request: t.objectField(config, "ticket_memory_request", self.ticket_memory_limit),
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
      ticket: [
        "ticket_cpu_limit",
      ],
    };

    local mem_metrics = {
      ticket: [
        "ticket_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
