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
      hdfs: {
        hdfs_data_storage: {
          storageClass: s.StorageClass,
          size: s.DiskDataSize,
          accessModes: ["ReadWriteOnce"],
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
        },
        hdfs_data_tmp_storage: {
          storageClass: s.StorageClass,
          size: s.DiskNormalSize,
          accessMode: "ReadWriteOnce",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
        },
        hdfs_name_data_storage: {
          storageClass: s.StorageClass,
          size: s.DiskDataSize,
          accessModes: ["ReadWriteOnce"],
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
        },
        hdfs_name_tmp_storage: {
          storageClass: s.StorageClass,
          size: s.DiskNormalSize,
          accessMode: "ReadWriteOnce",
          limits: {
            "blkio.throttle.read_iops_device": s.ReadIOPS,
            "blkio.throttle.write_iops_device": s.WriteIOPS,
          },
        },
      },
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
      hdfs:
        if Debug_Request then
          {
            hdfs_journal_cpu_limit: 0.2,
            hdfs_journal_memory_limit: 1,
            hdfs_journal_cpu_request: self.hdfs_journal_cpu_limit,
            hdfs_journal_memory_request: self.hdfs_journal_memory_limit,

            hdfs_name_cpu_limit: 0.4,
            hdfs_name_memory_limit: 2,
            hdfs_name_cpu_request: self.hdfs_name_cpu_limit,
            hdfs_name_memory_request: self.hdfs_name_memory_limit,

            hdfs_zkfc_cpu_limit: 0.4,
            hdfs_zkfc_memory_limit: 2,
            hdfs_zkfc_cpu_request: self.hdfs_zkfc_cpu_limit,
            hdfs_zkfc_memory_request: self.hdfs_zkfc_memory_limit,

            hdfs_data_cpu_limit: 0.2,
            hdfs_data_memory_limit: 1,
            hdfs_data_cpu_request: self.hdfs_data_cpu_limit,
            hdfs_data_memory_request: self.hdfs_data_memory_limit,

            hdfs_httpfs_cpu_limit: 0.2,
            hdfs_httpfs_memory_limit: 1,
            hdfs_httpfs_cpu_request: self.hdfs_httpfs_cpu_limit,
            hdfs_httpfs_memory_request: self.hdfs_httpfs_memory_limit,
          }
        else
          {
            hdfs_name_cpu_limit: t.objectField(config, "hdfs_name_cpu_limit", 4),
            hdfs_name_memory_limit: t.objectField(config, "hdfs_name_memory_limit", 8),

            hdfs_name_cpu_request: t.objectField(config, "hdfs_name_cpu_request", self.hdfs_name_cpu_limit),
            hdfs_name_memory_request: t.objectField(config, "hdfs_name_memory_request", self.hdfs_name_memory_limit),

            hdfs_data_cpu_limit: t.objectField(config, "hdfs_data_cpu_limit", 2),
            hdfs_data_memory_limit: t.objectField(config, "hdfs_data_memory_limit", 4),

            hdfs_data_cpu_request: t.objectField(config, "hdfs_data_cpu_request", self.hdfs_data_cpu_limit),
            hdfs_data_memory_request: t.objectField(config, "hdfs_data_memory_request", self.hdfs_data_memory_limit),

            // Use namenode as the achor point in dynamic resource distribution
            local cpu_limit = self.hdfs_name_cpu_limit,
            local memory_limit = self.hdfs_name_memory_limit,

            hdfs_journal_cpu_limit: t.objectField(config, "hdfs_journal_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            hdfs_journal_memory_limit: t.objectField(config, "hdfs_journal_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
            hdfs_journal_cpu_request: t.objectField(config, "hdfs_journal_cpu_request", self.hdfs_journal_cpu_limit),
            hdfs_journal_memory_request: t.objectField(config, "hdfs_journal_memory_request", self.hdfs_journal_memory_limit),

            hdfs_zkfc_cpu_limit: t.objectField(config, "hdfs_zkfc_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            hdfs_zkfc_memory_limit: t.objectField(config, "hdfs_zkfc_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
            hdfs_zkfc_cpu_request: t.objectField(config, "hdfs_zkfc_cpu_request", self.hdfs_zkfc_cpu_limit),
            hdfs_zkfc_memory_request: t.objectField(config, "hdfs_zkfc_memory_request", self.hdfs_zkfc_memory_limit),

            hdfs_httpfs_cpu_limit: t.objectField(config, "hdfs_httpfs_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            hdfs_httpfs_memory_limit: t.objectField(config, "hdfs_httpfs_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
            hdfs_httpfs_cpu_request: t.objectField(config, "hdfs_httpfs_cpu_request", self.hdfs_httpfs_cpu_limit),
            hdfs_httpfs_memory_request: t.objectField(config, "hdfs_httpfs_memory_request", self.hdfs_httpfs_memory_limit),
          },
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
            // Use namenode as the achor point
            local cpu_limit = resource.hdfs.hdfs_name_cpu_limit,
            local memory_limit = resource.hdfs.hdfs_name_memory_limit,

            zk_cpu_limit: t.objectField(config, "zk_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=cpu_limit)),
            zk_memory_limit: t.objectField(config, "zk_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=memory_limit)),
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
      hdfs: [
        "hdfs_name_cpu_limit",
        "hdfs_data_cpu_limit",
        "hdfs_zkfc_cpu_limit",
        "hdfs_httpfs_cpu_limit",
        "hdfs_journal_cpu_limit",
      ],
      zookeeper: [
        "zk_cpu_limit",
      ],
    };

    local mem_metrics = {
      hdfs: [
        "hdfs_name_memory_limit",
        "hdfs_data_memory_limit",
        "hdfs_zkfc_memory_limit",
        "hdfs_httpfs_memory_limit",
        "hdfs_journal_memory_limit",
      ],
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
