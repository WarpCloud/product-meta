# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      governor:
        {
          governor_cpu_limit: t.objectField(config, "governor_cpu_limit", 4),
          governor_memory_limit: t.objectField(config, "governor_memory_limit", 8),
          governor_cpu_request: t.objectField(config, "governor_cpu_request", 0.1),
          governor_memory_request: t.objectField(config, "governor_memory_request", 1),
        },
      notification:
        {
          local cpu_limit = resource.governor.governor_cpu_limit,
          local memory_limit = resource.governor.governor_memory_limit,

          notification_cpu_limit: t.objectField(config, "notification_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=4)),
          notification_memory_limit: t.objectField(config, "notification_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          notification_cpu_request: t.objectField(config, "notification_cpu_request", 0.1),
          notification_memory_request: t.objectField(config, "notification_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
