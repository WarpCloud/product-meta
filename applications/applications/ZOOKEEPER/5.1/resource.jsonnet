# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);
    local s = t.extractStorageParams(config);

    local storage = {
      zookeeper: {
        zk_storage_config: t.assembleStorageEntry(config, "zk_storage_config", s.StorageClass, s.DiskNormalSize, kind="pvc"),
      }
    };

    local resource = {
      zookeeper:
        {
          zk_cpu_limit: t.objectField(config, "zk_cpu_limit", 1),
          zk_memory_limit: t.objectField(config, "zk_memory_limit", 4),
          zk_cpu_request: t.objectField(config, "zk_cpu_request", 0.1),
          zk_memory_request: t.objectField(config, "zk_memory_request", 1),
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
