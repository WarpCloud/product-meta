# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local s = t.extractStorageParams(config);

    local storage = {};

    local resource = {
      hyperbase:
        {
          hbase_master_cpu_limit: t.objectField(config, "hbase_master_cpu_limit", 4),
          hbase_master_memory_limit: t.objectField(config, "hbase_master_memory_limit", 4),
          hbase_master_cpu_request: t.objectField(config, "hbase_master_cpu_request", 0.1),
          hbase_master_memory_request: t.objectField(config, "hbase_master_memory_request", 2),

          hbase_rs_cpu_limit: t.objectField(config, "hbase_rs_cpu_limit", 2),
          hbase_rs_memory_limit: t.objectField(config, "hbase_rs_memory_limit", 1),
          hbase_rs_cpu_request: t.objectField(config, "hbase_rs_cpu_request", 0.1),
          hbase_rs_memory_request: t.objectField(config, "hbase_rs_memory_request", 1),

          // Use namenode as the achor point in dynamic resource distribution
          local cpu_limit = self.hbase_rs_cpu_limit,
          local memory_limit = self.hbase_rs_memory_limit,

          hbase_rest_cpu_limit: t.objectField(config, "hbase_rest_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
          hbase_rest_memory_limit: t.objectField(config, "hbase_rest_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
          hbase_rest_cpu_request: t.objectField(config, "hbase_rest_cpu_request", 0.1),
          hbase_rest_memory_request: t.objectField(config, "hbase_rest_memory_request", 1),

          hbase_thrift_cpu_limit: t.objectField(config, "hbase_thrift_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
          hbase_thrift_memory_limit: t.objectField(config, "hbase_thrift_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
          hbase_thrift_cpu_request: t.objectField(config, "hbase_thrift_cpu_request", 0.1),
          hbase_thrift_memory_request: t.objectField(config, "hbase_thrift_memory_request", 1),
        },
    };
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
      hyperbase: [
        "hbase_master_cpu_limit",
        "hbase_rs_cpu_limit",
        "hbase_rest_cpu_limit",
        "hbase_thrift_cpu_limit",
      ],
    };

    local mem_metrics = {
      hyperbase: [
        "hbase_master_memory_limit",
        "hbase_rs_memory_limit",
        "hbase_rest_memory_limit",
        "hbase_thrift_memory_limit",
      ],
    };

    local ssd_metrics = {

    };

    local disk_metrics = {

    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics, ssd_metrics, disk_metrics),
}
