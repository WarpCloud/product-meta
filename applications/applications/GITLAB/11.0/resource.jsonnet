# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      gitlab:
        {
          gitlab_cpu_limit: t.objectField(config, "gitlab_cpu_limit", 1),
          gitlab_memory_limit: t.objectField(config, "gitlab_memory_limit", 1),
          gitlab_cpu_request: t.objectField(config, "gitlab_cpu_request", 1),
          gitlab_memory_request: t.objectField(config, "gitlab_memory_request", 1),
          redis_cpu_limit: t.objectField(config, "redis_cpu_limit", 1),
          redis_memory_limit: t.objectField(config, "redis_memory_limit", 1),
          redis_cpu_request: t.objectField(config, "redis_cpu_request", 1),
          redis_memory_request: t.objectField(config, "redis_memory_request", 1),
          postgresql_cpu_limit: t.objectField(config, "postgresql_cpu_limit", 1),
          postgresql_memory_limit: t.objectField(config, "postgresql_memory_limit", 1),
          postgresql_cpu_request: t.objectField(config, "postgresql_cpu_request", 1),
          postgresql_memory_request: t.objectField(config, "postgresql_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
