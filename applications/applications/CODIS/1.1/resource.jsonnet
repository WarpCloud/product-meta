# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);
    local storage = {};
    local resource = {
      codis:
        {
          codis_server_cpu_limit: t.objectField(config, "codis_server_cpu_limit", 1),
          codis_server_memory_limit: t.objectField(config, "codis_server_memory_limit", 4),
          codis_server_cpu_request: t.objectField(config, "codis_server_cpu_request", 0.1),
          codis_server_memory_request: t.objectField(config, "codis_server_memory_request", 2),

          // Use server as the achor point in dynamic resource distribution
          local cpu_limit = self.codis_server_cpu_limit,
          local memory_limit = self.codis_server_memory_limit,

          codis_dash_cpu_limit: t.objectField(config, "codis_dash_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=1)),
          codis_dash_memory_limit: t.objectField(config, "codis_dash_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=2)),
          codis_dash_cpu_request: t.objectField(config, "codis_dash_cpu_request", 0.1),
          codis_dash_memory_request: t.objectField(config, "codis_dash_memory_request", 1),

          codis_proxy_cpu_limit: t.objectField(config, "codis_proxy_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=1)),
          codis_proxy_memory_limit: t.objectField(config, "codis_proxy_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=2)),
          codis_proxy_cpu_request: t.objectField(config, "codis_proxy_cpu_request", 0.1),
          codis_proxy_memory_request: t.objectField(config, "codis_proxy_memory_request", 1),

          codis_fe_cpu_limit: t.objectField(config, "codis_fe_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=1)),
          codis_fe_memory_limit: t.objectField(config, "codis_fe_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=2)),
          codis_fe_cpu_request: t.objectField(config, "codis_fe_cpu_request", 0.1),
          codis_fe_memory_request: t.objectField(config, "codis_fe_memory_request", 1)
        },
    };
    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
