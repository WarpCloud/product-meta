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
        {
          discover_cpu_limit: t.objectField(config, "discover_cpu_limit", 4),
          discover_memory_limit: t.objectField(config, "discover_memory_limit", 8),
          discover_cpu_request: t.objectField(config, "discover_cpu_request", 0.1),
          discover_memory_request: t.objectField(config, "discover_memory_request", 1),
        },
      localcran:
        {
          local cpu_limit = resource.discover.discover_cpu_limit,
          local memory_limit = resource.discover.discover_memory_limit,

          localcran_cpu_limit: t.objectField(config, "localcran_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          localcran_memory_limit: t.objectField(config, "localcran_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          localcran_cpu_request: t.objectField(config, "localcran_cpu_request", 0.1),
          localcran_memory_request: t.objectField(config, "localcran_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
