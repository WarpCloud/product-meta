# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local s = t.extractStorageParams(config);

    local resource = {
      logstash:
        {
          logstash_cpu_limit: t.objectField(config, "logstash_cpu_limit", 1),
          logstash_memory_limit: t.objectField(config, "logstash_memory_limit", 2),
          logstash_cpu_request: t.objectField(config, "logstash_cpu_request", 0.1),
          logstash_memory_request: t.objectField(config, "logstash_memory_request", 1),
          local _logstash_heap_size_in_mb = t.objectField(config, "logstash_memory_limit", 2) * 0.6 * 1024,
          logstash_heap_size: std.toString(std.floor(_logstash_heap_size_in_mb)) + "m",
        },
    };

    local storage = {
      logstash: {
        logstash_tmp_storage: t.assembleStorageEntry(config, "logstash_tmp_storage", s.StorageClass, s.DiskTmpSize, kind="tosdisk"),
      }
    };

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
