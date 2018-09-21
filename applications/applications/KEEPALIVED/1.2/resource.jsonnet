# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      catalog:
        {
          keepalived_cpu_limit: t.objectField(config, "keepalived_cpu_limit", 1),
          keepalived_cpu_request: t.objectField(config, "keepalived_cpu_request", 1),
          keepalived_memory_limit: t.objectField(config, "keepalived_memory_limit", 4),
          keepalived_memory_request: t.objectField(config, "keepalived_memory_request", 0.1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
