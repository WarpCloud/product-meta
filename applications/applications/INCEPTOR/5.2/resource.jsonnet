# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      inceptor:
        {
          inceptor_master_cpu_limit: t.objectField(config, "inceptor_master_cpu_limit", 1),
          inceptor_master_memory_limit: t.objectField(config, "inceptor_master_memory_limit", 4),
          inceptor_master_cpu_request: t.objectField(config, "inceptor_master_cpu_request", 1),
          inceptor_master_memory_request: t.objectField(config, "inceptor_master_memory_request", 1),

          inceptor_executor_cpu_limit: t.objectField(config, "inceptor_executor_cpu_limit", 1),
          inceptor_executor_memory_limit: t.objectField(config, "inceptor_executor_memory_limit", 4),
          inceptor_executor_cpu_request: t.objectField(config, "inceptor_executor_cpu_request", 1),
          inceptor_executor_memory_request: t.objectField(config, "inceptor_executor_memory_request", 4),
        },
      metastore:
        {
          local cpu_limit = resource.inceptor.inceptor_master_cpu_limit,
          local memory_limit = resource.inceptor.inceptor_master_memory_limit,

          metastore_cpu_limit: t.objectField(config, "metastore_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          metastore_memory_limit: t.objectField(config, "metastore_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=8)),
          metastore_cpu_request: t.objectField(config, "metastore_cpu_request", 0.1),
          metastore_memory_request: t.objectField(config, "metastore_memory_request", 1),

          mysql_cpu_limit: t.objectField(config, "mysql_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          mysql_memory_limit: t.objectField(config, "mysql_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          mysql_cpu_request: t.objectField(config, "mysql_cpu_request", 0.1),
          mysql_memory_request: t.objectField(config, "mysql_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },
}
