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
        {
          abacus_cpu_limit: t.objectField(config, "abacus_cpu_limit", 1),
          abacus_memory_limit: t.objectField(config, "abacus_memory_limit", 4),
          abacus_cpu_request: t.objectField(config, "abacus_cpu_request", 0.1),
          abacus_memory_request: t.objectField(config, "abacus_memory_request", 1),

          scanner_cpu_limit: t.objectField(config, "scanner_cpu_limit", 1),
          scanner_memory_limit: t.objectField(config, "scanner_memory_limit", 4),
          scanner_cpu_request: t.objectField(config, "scanner_cpu_request", 0.1),
          scanner_memory_request: t.objectField(config, "scanner_memory_request", 1),
        },
      gondar:
        {
          local cpu_limit = resource.tenon.abacus_cpu_limit,
          local memory_limit = resource.tenon.abacus_memory_limit,

          gondar_udr_cpu_limit: t.objectField(config, "gondar_udr_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
          gondar_udr_memory_limit: t.objectField(config, "gondar_udr_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          gondar_udr_cpu_request: t.objectField(config, "gondar_udr_cpu_request", 0.1),
          gondar_udr_memory_request: t.objectField(config, "gondar_udr_memory_request", 1),

          gondar_cdr_cpu_limit: t.objectField(config, "gondar_cdr_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
          gondar_cdr_memory_limit: t.objectField(config, "gondar_cdr_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          gondar_cdr_cpu_request: t.objectField(config, "gondar_cdr_cpu_request", 0.1),
          gondar_cdr_memory_request: t.objectField(config, "gondar_cdr_memory_request", 1),

          gondar_billing_cpu_limit: t.objectField(config, "gondar_billing_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
          gondar_billing_memory_limit: t.objectField(config, "gondar_billing_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          gondar_billing_cpu_request: t.objectField(config, "gondar_billing_cpu_request", 0.1),
          gondar_billing_memory_request: t.objectField(config, "gondar_billing_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
