# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      txsql:
        if Debug_Request then
          {
            txsql_cpu_limit: 0.5,
            txsql_memory_limit: 1,
            txsql_cpu_request: self.txsql_cpu_limit,
            txsql_memory_request: self.txsql_memory_limit,
          }
        else
          {
            txsql_cpu_limit: t.objectField(config, "txsql_cpu_limit", 2),
            txsql_memory_limit: t.objectField(config, "txsql_memory_limit", 4),
            txsql_cpu_request: t.objectField(config, "txsql_cpu_request", self.txsql_cpu_limit),
            txsql_memory_request: t.objectField(config, "txsql_memory_request", self.txsql_memory_limit),
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
      txsql: [
        "txsql_cpu_limit",
      ],
    };

    local mem_metrics = {
      txsql: [
        "txsql_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
