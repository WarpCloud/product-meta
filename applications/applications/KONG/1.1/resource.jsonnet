# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      kong:
        {
          kong_cpu_limit: t.objectField(config, "kong_cpu_limit", 1),
          kong_memory_limit: t.objectField(config, "kong_memory_limit", 1),
          kong_cpu_request: t.objectField(config, "kong_cpu_request", 0.1),
          kong_memory_request: t.objectField(config, "kong_memory_request", 1),
        },
      "kong-dashboard":
        {
          kong_dashboard_cpu_limit: t.objectField(config, "kong_dashboard_cpu_limit", 1),
          kong_dashboard_memory_limit: t.objectField(config, "kong_dashboard_memory_limit", 1),
          kong_dashboard_cpu_request: t.objectField(config, "kong_dashboard_cpu_request", 0.1),
          kong_dashboard_memory_request: t.objectField(config, "kong_dashboard_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
