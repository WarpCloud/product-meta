# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      guardian:
        if Debug_Request then
          {
            guardian_cpu_limit: 0.2,
            guardian_memory_limit: 2,
          }
        else
          {
            guardian_cpu_limit: t.objectField(config, "guardian_cpu_limit", 4),
            guardian_memory_limit: t.objectField(config, "guardian_memory_limit", 8),
          },
      cas:
        if Debug_Request then
          {
            cas_server_cpu_limit: 0.2,
            cas_server_memory_limit: 2,
            cas_mgnt_server_cpu_limit: self.cas_server_cpu_limit,
            cas_mgnt_server_memory_limit: self.cas_server_memory_limit,
            cas_config_server_cpu_limit: self.cas_server_cpu_limit,
            cas_config_server_memory_limit: self.cas_server_memory_limit,
          }
        else
          {
            local cpu_limit = resource.guardian.guardian_cpu_limit,
            local memory_limit = resource.guardian.guardian_memory_limit,

            cas_server_cpu_limit: t.objectField(config, "cas_server_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            cas_server_memory_limit: t.objectField(config, "cas_server_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
            cas_mgnt_server_cpu_limit: t.objectField(config, "cas_mgnt_server_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            cas_mgnt_server_memory_limit: t.objectField(config, "cas_mgnt_server_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
            cas_config_server_cpu_limit: t.objectField(config, "cas_config_server_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            cas_config_server_memory_limit: t.objectField(config, "cas_config_server_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
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

  /*
   * Define TCU calculation for each module
   */
  moduleTCU(moduleName, config={})::
    local cpu_metrics = {
      guardian: [
        "guardian_cpu_limit",
      ],
      cas: [
        "cas_server_cpu_limit",
        "cas_mgnt_server_cpu_limit",
        "cas_config_server_cpu_limit"
      ],
    };

    local mem_metrics = {
      guardian: [
        "guardian_memory_limit",
      ],
      cas: [
        "cas_server_memory_limit",
        "cas_mgnt_server_memory_limit",
        "cas_config_server_memory_limit"
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
