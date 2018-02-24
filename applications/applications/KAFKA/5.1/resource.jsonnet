# Copyright 2016 Transwarp Inc. All rights reserved.

local t = import "../../../applib/utils.libsonnet";

{
  local _kafkaModuleName = "kafka",
  local _kafkaManagerModuleName = "kafka-manager",

  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local s = t.extractStorageParams(config);

    local storage = {
      [_kafkaModuleName]: {
        kafka_tmp_storage: t.assembleStorageEntry(config, "kafka_tmp_storage", s.StorageClass, s.DiskTmpSize),
        kafka_storage_config: t.assembleStorageEntry(config, "kafka_storage_config", s.StorageClass, s.DiskDataSize),
      },
    };

    local resource = {
      [_kafkaModuleName]:
        {
          kafka_cpu_limit: t.objectField(config, "kafka_cpu_limit", 1),
          kafka_memory_limit: t.objectField(config, "kafka_memory_limit", 2),
          kafka_cpu_request: t.objectField(config, "kafka_cpu_request", 0.1),
          kafka_memory_request: t.objectField(config, "kafka_memory_request", 1),
        },
      [_kafkaManagerModuleName]:
        {
          local cpu_limit = resource[_kafkaModuleName].kafka_cpu_limit,
          local memory_limit = resource[_kafkaModuleName].kafka_memory_limit,

          kafka_manager_cpu_limit: t.objectField(config, "kafka_manager_cpu_limit", cpu_limit),
          kafka_manager_memory_limit: t.objectField(config, "kafka_manager_memory_limit", memory_limit),
          kafka_manager_cpu_request: t.objectField(config, "kafka_manager_cpu_request", 0.1),
          kafka_manager_memory_request: t.objectField(config, "kafka_manager_memory_request", 1),
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
