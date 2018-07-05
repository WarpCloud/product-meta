# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      filebeat:
        {
          filebeat_cpu_limit: t.objectField(config, "filebeat_cpu_limit", 1),
          filebeat_memory_limit: t.objectField(config, "filebeat_memory_limit", 2),
          filebeat_cpu_request: t.objectField(config, "filebeat_cpu_request", 0.1),
          filebeat_memory_request: t.objectField(config, "filebeat_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
