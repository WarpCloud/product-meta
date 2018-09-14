# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      weblogic:
        {
          admin_cpu_limit: t.objectField(config, "admin_cpu_limit", 1),
          admin_memory_limit: t.objectField(config, "admin_memory_limit", 4),
          admin_cpu_request: t.objectField(config, "admin_cpu_request", 0.1),
          admin_memory_request: t.objectField(config, "admin_memory_request", 1),

          ms_cpu_limit: t.objectField(config, "ms_cpu_limit", 1),
          ms_memory_limit: t.objectField(config, "ms_memory_limit", 4),
          ms_cpu_request: t.objectField(config, "ms_cpu_request", 0.1),
          ms_memory_request: t.objectField(config, "ms_memory_request", 1),
        },
    };

    local storage = {
      weblogic:
        {
          admin_storage_limit: t.objectField(config, "admin_storage_limit", 10),
          ms_storage_limit: t.objectField(config, "ms_storage_limit", 20),
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
}
