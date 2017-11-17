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
        if Debug_Request then
          {
            logstash_cpu_limit: 0.2,
            logstash_memory_limit: 1,
            logstash_cpu_request: self.logstash_cpu_limit,
            logstash_memory_request: self.logstash_memory_limit,
          }
        else
          {
            logstash_cpu_limit: t.objectField(config, "logstash_cpu_limit", 1),
            logstash_memory_limit: t.objectField(config, "logstash_memory_limit", 2),
            logstash_cpu_request: t.objectField(config, "logstash_cpu_request", self.logstash_cpu_limit),
            logstash_memory_request: t.objectField(config, "logstash_memory_request", self.logstash_memory_limit),
          },
    };

    local storage = {
      logstash: {
        logstash_tmp_storage: {
          storageClass: s.StorageClass,
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
          size: s.DiskTmpSize,
          accessMode: "ReadWriteOnce",
        },
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

  /*
   * Define TCU calculation for each module
   */
  moduleTCU(moduleName, config={})::
    local cpu_metrics = {
      logstash: [
        "logstash_cpu_limit",
      ],
    };

    local mem_metrics = {
      logstash: [
        "logstash_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
