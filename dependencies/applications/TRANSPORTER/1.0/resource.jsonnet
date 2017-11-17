# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      tdt:
        if Debug_Request then
          {
            tdt_cpu_limit: 0.5,
            tdt_memory_limit: 2,
            tdt_cpu_request: self.tdt_cpu_limit,
            tdt_memory_request: self.tdt_memory_limit,
          }
        else
          {
            tdt_cpu_limit: t.objectField(config, "tdt_cpu_limit", 1),
            tdt_memory_limit: t.objectField(config, "tdt_memory_limit", 4),
            tdt_cpu_request: t.objectField(config, "tdt_cpu_request", self.tdt_cpu_limit),
            tdt_memory_request: t.objectField(config, "tdt_memory_request", self.tdt_memory_limit),
          },
    };

    local s = t.extractStorageParams(config);

    local storage = {
      tdt: {
        tdt_tmp_storage: {
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
      tdt: [
        "tdt_cpu_limit",
      ],
    };

    local mem_metrics = {
      tdt: [
        "tdt_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
