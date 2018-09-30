# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      ogg:
        {
          ogg_cpu_limit: t.objectField(config, "ogg_cpu_limit", 1),
          ogg_memory_limit: t.objectField(config, "ogg_memory_limit", 4),
          ogg_cpu_request: t.objectField(config, "ogg_cpu_request", 0.1),
          ogg_memory_request: t.objectField(config, "ogg_memory_request", 1),
        },
    };

    local s = t.extractStorageParams(config);

    local storage = {
      ogg: {
        ogg_tmp_storage: t.assembleStorageEntry(config, "ogg_tmp_storage", s.DiskTmpStorageClass, s.DiskTmpSize, kind="tosdisk")
      }
    };

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
