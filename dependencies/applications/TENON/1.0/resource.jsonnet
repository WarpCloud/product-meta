# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      tenon:
        if Debug_Request then
          {
            abacus_cpu_limit: 0.1,
            abacus_memory_limit: 2,
            scanner_cpu_limit: self.abacus_cpu_limit,
            scanner_memory_limit: self.abacus_memory_limit,
          }
        else
          {
            abacus_cpu_limit: t.objectField(config, "abacus_cpu_limit", 1),
            abacus_memory_limit: t.objectField(config, "abacus_memory_limit", 4),
            scanner_cpu_limit: t.objectField(config, "scanner_cpu_limit", self.abacus_cpu_limit),
            scanner_memory_limit: t.objectField(config, "scanner_memory_limit", self.abacus_memory_limit),
          },
      gondar:
        if Debug_Request then
          {
            gondar_udr_cpu_limit: 0.1,
            gondar_udr_memory_limit: 2,
            gondar_cdr_cpu_limit: self.gondar_udr_cpu_limit,
            gondar_cdr_memory_limit: self.gondar_udr_memory_limit,
            gondar_billing_cpu_limit: self.gondar_udr_cpu_limit,
            gondar_billing_memory_limit: self.gondar_udr_memory_limit,
          }
        else
          {
            local cpu_limit = resource.tenon.abacus_cpu_limit,
            local memory_limit = resource.tenon.abacus_memory_limit,

            gondar_udr_cpu_limit: t.objectField(config, "gondar_udr_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
            gondar_udr_memory_limit: t.objectField(config, "gondar_udr_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
            gondar_cdr_cpu_limit: t.objectField(config, "gondar_cdr_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
            gondar_cdr_memory_limit: t.objectField(config, "gondar_cdr_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
            gondar_billing_cpu_limit: t.objectField(config, "gondar_billing_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
            gondar_billing_memory_limit: t.objectField(config, "gondar_billing_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
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
      tenon: [
        "abacus_cpu_limit",
        "scanner_cpu_limit",
      ],
      gondar: [
        "gondar_udr_cpu_limit",
        "gondar_cdr_cpu_limit",
        "gondar_billing_cpu_limit"
      ],
    };

    local mem_metrics = {
      tenon: [
        "abacus_memory_limit",
        "scanner_memory_limit"
      ],
      gondar: [
        "gondar_udr_memory_limit",
        "gondar_cdr_memory_limit",
        "gondar_billing_memory_limit"
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
