# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  local _gtModuleName = "gn-tenant",
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      _gtModuleName:
        {
          gn_cpu_limit: t.objectField(config, "gn_cpu_limit", 2),
          gn_memory_limit: t.objectField(config, "gn_memory_limit", 2),
          gn_cpu_request: t.objectField(config, "gn_cpu_request", 0.1),
          gn_memory_request: t.objectField(config, "gn_memory_request", 0.5),
        },
    };

    local storage = {};

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
