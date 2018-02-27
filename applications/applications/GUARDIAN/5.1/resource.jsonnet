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
      guardian:
        {
          guardian_server_cpu_limit: t.objectField(config, "guardian_server_cpu_limit", 4),
          guardian_server_memory_limit: t.objectField(config, "guardian_server_memory_limit", 8),
          guardian_server_cpu_request: t.objectField(config, "guardian_server_cpu_request", 0.1),
          guardian_server_memory_request: t.objectField(config, "guardian_server_memory_request", 1),

          apacheds_cpu_limit: t.objectField(config, "apacheds_cpu_limit", 1),
          apacheds_memory_limit: t.objectField(config, "apacheds_memory_limit", 2),
          apacheds_cpu_request: t.objectField(config, "apacheds_cpu_request", 0.1),
          apacheds_memory_request: t.objectField(config, "apacheds_memory_request", 1),
        },
      cas:
        {
          local cpu_limit = resource.guardian.guardian_server_cpu_limit,
          local memory_limit = resource.guardian.guardian_server_cpu_limit,

          cas_server_cpu_limit: t.objectField(config, "cas_server_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
          cas_server_memory_limit: t.objectField(config, "cas_server_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
          cas_mgnt_server_cpu_limit: t.objectField(config, "cas_mgnt_server_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
          cas_mgnt_server_memory_limit: t.objectField(config, "cas_mgnt_server_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
          cas_config_server_cpu_limit: t.objectField(config, "cas_config_server_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
          cas_config_server_memory_limit: t.objectField(config, "cas_config_server_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),

          cas_server_cpu_request: t.objectField(config, "cas_server_cpu_request", 0.1),
          cas_server_memory_request: t.objectField(config, "cas_server_memory_request", 1),
          cas_mgnt_server_cpu_request: t.objectField(config, "cas_mgnt_server_cpu_request", 0.1),
          cas_mgnt_server_memory_request: t.objectField(config, "cas_mgnt_server_memory_request", 1),
          cas_config_server_cpu_request: t.objectField(config, "cas_config_server_cpu_request", 0.1),
          cas_config_server_memory_request: t.objectField(config, "cas_config_server_memory_request", 1),
        },
    };

    local storage = {
      guardian: {
        guardian_server_volume_storage: t.assembleStorageEntry(config, "guardian_server_volume_storage", s.StorageClass, s.DiskNormalSize, kind="tosdisk"),
      }
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
