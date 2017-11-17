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
        zk_storage_config: {
          storageClass: s.StorageClass,
          size: s.DiskNormalSize,
          accessModes: ["ReadWriteOnce"],
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
        },
      }
    };

    local resource = {
      zookeeper:
        if Debug_Request then
          {
            zk_cpu_limit: 0.2,
            zk_memory_limit: 1,
            zk_cpu_request: self.zk_cpu_limit,
            zk_memory_request: self.zk_memory_limit,
          }
        else
          {
            zk_cpu_limit: t.objectField(config, "zk_cpu_limit", 1),
            zk_memory_limit: t.objectField(config, "zk_memory_limit", 4),
            zk_cpu_request: t.objectField(config, "zk_cpu_request", self.zk_cpu_limit),
            zk_memory_request: t.objectField(config, "zk_memory_request", self.zk_memory_limit),
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

  /*
   * Define TCU calculation for each module
   */
  moduleTCU(moduleName, config={})::
    local unifiedConfig = t.getUnifiedInstanceSettings(config);

    local cpu_metrics = {
      zookeeper: [
        "zk_cpu_limit",
      ],
    };

    local mem_metrics = {
      zookeeper: [
        "zk_memory_limit",
      ],
    };

    local ssd_metrics = {

    };

    local disk_metrics = {

    };

    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics, ssd_metrics, disk_metrics),
}
