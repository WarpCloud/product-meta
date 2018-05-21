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
        hdfs_data_storage: t.assembleStorageEntry(config, "hdfs_data_storage", s.StorageClass, s.DiskDataSize, kind="pvc"),
        hdfs_data_tmp_storage: t.assembleStorageEntry(config, "hdfs_data_tmp_storage", s.StorageClass, s.DiskTmpSize, kind="tosdisk"),
        hdfs_name_data_storage: t.assembleStorageEntry(config, "hdfs_name_data_storage", s.StorageClass, s.DiskNormalSize, kind="pvc"),
        hdfs_name_tmp_storage: t.assembleStorageEntry(config, "hdfs_name_tmp_storage", s.StorageClass, s.DiskTmpSize, kind="tosdisk"),
      },
      zookeeper: {
        zk_storage_config: t.assembleStorageEntry(config, "zk_storage_config", s.StorageClass, s.DiskNormalSize, kind="pvc"),
      }
    };

    local resource = {
      hdfs:
        {
          hdfs_name_cpu_limit: t.objectField(config, "hdfs_name_cpu_limit", 4),
          hdfs_name_memory_limit: t.objectField(config, "hdfs_name_memory_limit", 8),
          hdfs_name_cpu_request: t.objectField(config, "hdfs_name_cpu_request", 0.1),
          hdfs_name_memory_request: t.objectField(config, "hdfs_name_memory_request", 2),

          hdfs_data_cpu_limit: t.objectField(config, "hdfs_data_cpu_limit", 2),
          hdfs_data_memory_limit: t.objectField(config, "hdfs_data_memory_limit", 4),
          hdfs_data_cpu_request: t.objectField(config, "hdfs_data_cpu_request", 0.1),
          hdfs_data_memory_request: t.objectField(config, "hdfs_data_memory_request", 1),

          // Use namenode as the achor point in dynamic resource distribution
          local cpu_limit = self.hdfs_name_cpu_limit,
          local memory_limit = self.hdfs_name_memory_limit,

          hdfs_journal_cpu_limit: t.objectField(config, "hdfs_journal_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          hdfs_journal_memory_limit: t.objectField(config, "hdfs_journal_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          hdfs_journal_cpu_request: t.objectField(config, "hdfs_journal_cpu_request", 0.1),
          hdfs_journal_memory_request: t.objectField(config, "hdfs_journal_memory_request", 1),

          hdfs_zkfc_cpu_limit: t.objectField(config, "hdfs_zkfc_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          hdfs_zkfc_memory_limit: t.objectField(config, "hdfs_zkfc_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          hdfs_zkfc_cpu_request: t.objectField(config, "hdfs_zkfc_cpu_request", 0.1),
          hdfs_zkfc_memory_request: t.objectField(config, "hdfs_zkfc_memory_request", 2),

          hdfs_httpfs_cpu_limit: t.objectField(config, "hdfs_httpfs_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          hdfs_httpfs_memory_limit: t.objectField(config, "hdfs_httpfs_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
          hdfs_httpfs_cpu_request: t.objectField(config, "hdfs_httpfs_cpu_request", 0.1),
          hdfs_httpfs_memory_request: t.objectField(config, "hdfs_httpfs_memory_request", 1),
        },
      zookeeper:
        {
          // Use namenode as the achor point
          local cpu_limit = resource.hdfs.hdfs_name_cpu_limit,
          local memory_limit = resource.hdfs.hdfs_name_memory_limit,

          zk_cpu_limit: t.objectField(config, "zk_cpu_limit", t.raRange(cpu_limit * 0.5, min=1, max=2)),
          zk_memory_limit: t.objectField(config, "zk_memory_limit", t.raRange(memory_limit * 0.5, min=1, max=4)),
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
