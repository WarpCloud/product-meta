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
      elasticsearch: {
        es_client_storage: t.assembleStorageEntry(config, "es_client_storage", s.StorageClass, s.DiskNormalSize, kind="pvc"),
        es_data_storage: t.assembleStorageEntry(config, "es_data_storage", s.StorageClass, s.DiskDataSize, kind="pvc"),
        es_master_storage: t.assembleStorageEntry(config, "es_master_storage", s.StorageClass, s.DiskNormalSize, kind="pvc"),
      },
    };

    local resource = {
      elasticsearch:
        {
          es_master_cpu_limit: t.objectField(config, "es_master_cpu_limit", 1),
          es_master_memory_limit: t.objectField(config, "es_master_memory_limit", 4),
          es_master_cpu_request: t.objectField(config, "es_master_cpu_request", 0.1),
          es_master_memory_request: t.objectField(config, "es_master_memory_request", 2),

          local cpu_limit = self.es_master_cpu_limit,
          local memory_limit = self.es_master_memory_limit,
          local _es_data_memory_limit = t.objectField(config, "es_data_memory_limit", t.raRange(memory_limit, min=2, max=memory_limit)),

          es_data_cpu_limit: t.objectField(config, "es_data_cpu_limit", t.raRange(cpu_limit, min=1, max=cpu_limit)),
          es_data_memory_limit: _es_data_memory_limit,
          es_data_cpu_request: t.objectField(config, "es_data_cpu_request", 0.1),
          es_data_memory_request: t.objectField(config, "es_data_memory_request", 2),

          es_client_cpu_limit: t.objectField(config, "es_client_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
          es_client_memory_limit: t.objectField(config, "es_client_memory_limit", t.raRange(memory_limit * 0.5, min=2, max=memory_limit)),
          es_client_cpu_request: t.objectField(config, "es_client_cpu_request", 0.1),
          es_client_memory_request: t.objectField(config, "es_client_memory_request", 2),

          # Add ES head size, WARP-21420
          es_data_env_list: t.objectField(config, "es_data_env_list", []) + [
            {
              "key": "ES_HEAP_SIZE",
              "value": std.toString(t.raRange(std.floor(_es_data_memory_limit * 0.6), min=1, max=32))
            }
          ]
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
