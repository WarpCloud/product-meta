# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      yarn:
        if Debug_Request then
          {
            yarn_node_cpu_limit: 0.5,
            yarn_node_memory_limit: 1,
            yarn_node_cpu_request: self.yarn_node_cpu_limit,
            yarn_node_memory_request: self.yarn_node_memory_limit,

            yarn_rm_cpu_limit: 0.5,
            yarn_rm_memory_limit: 1,
            yarn_rm_cpu_request: self.yarn_rm_cpu_limit,
            yarn_rm_memory_request: self.yarn_rm_memory_limit,
          }
        else
          {
            yarn_node_cpu_limit: t.objectField(config, "yarn_node_cpu_limit", 1),
            yarn_node_memory_limit: t.objectField(config, "yarn_node_memory_limit", 2),
            yarn_node_cpu_request: t.objectField(config, "yarn_node_cpu_request", self.yarn_node_cpu_limit),
            yarn_node_memory_request: t.objectField(config, "yarn_node_memory_request", self.yarn_node_memory_limit),

            yarn_rm_cpu_limit: t.objectField(config, "yarn_rm_cpu_limit", self.yarn_node_cpu_limit),
            yarn_rm_memory_limit: t.objectField(config, "yarn_rm_memory_limit", self.yarn_node_memory_limit),
            yarn_rm_cpu_request: t.objectField(config, "yarn_rm_cpu_request", self.yarn_rm_cpu_limit),
            yarn_rm_memory_request: t.objectField(config, "yarn_rm_memory_request", self.yarn_rm_memory_limit),
          },
    };

    local s = t.extractStorageParams(config);

    local storage = {
      yarn: {
        yarn_resourcemanager_tmp_storage: {
          storageClass: "silver",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
          size: s.DiskTmpSize,
          accessMode: "ReadWriteOnce",
        },
        yarn_secondary_tmp_storage: {
          storageClass: "silver",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
          size: s.DiskTmpSize,
          accessMode: "ReadWriteOnce",
        },
        yarn_historyserver_tmp_storage: {
          storageClass: "silver",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
          size: s.DiskTmpSize,
          accessMode: "ReadWriteOnce",
        },
        yarn_nodemanager_tmp_storage: {
          storageClass: "silver",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
          size: s.DiskTmpSize,
          accessMode: "ReadWriteOnce",
        },
        yarn_nodemanager_data_storage: {
          storageClass: "silver",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
          size: s.DiskTmpSize,
          accessMode: "ReadWriteOnce",
        },
        yarn_timelineserver_tmp_storage: {
          storageClass: "silver",
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
      yarn: [
        "yarn_node_cpu_limit",
        "yarn_rm_cpu_limit",
      ],
    };

    local mem_metrics = {
      yarn: [
        "yarn_node_memory_limit",
        "yarn_rm_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
