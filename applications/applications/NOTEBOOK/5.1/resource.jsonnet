# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      notebook:
        {
          notebook_cpu_limit: t.objectField(config, "notebook_cpu_limit", 2),
          notebook_memory_limit: t.objectField(config, "notebook_memory_limit", 4),
          notebook_cpu_request: t.objectField(config, "notebook_cpu_request", 0.1),
          notebook_memory_request: t.objectField(config, "notebook_memory_request", 1),
        },
      localcran:
        {
          local cpu_limit = resource.notebook.notebook_cpu_limit,
          local memory_limit = resource.notebook.notebook_memory_limit,

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
