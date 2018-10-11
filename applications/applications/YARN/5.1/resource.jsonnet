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
        {
          yarn_node_cpu_limit: t.objectField(config, "yarn_node_cpu_limit", 1),
          yarn_node_memory_limit: t.objectField(config, "yarn_node_memory_limit", 2),
          yarn_node_cpu_request: t.objectField(config, "yarn_node_cpu_request", 0.1),
          yarn_node_memory_request: t.objectField(config, "yarn_node_memory_request", 1),

          yarn_rm_cpu_limit: t.objectField(config, "yarn_rm_cpu_limit", self.yarn_node_cpu_limit),
          yarn_rm_memory_limit: t.objectField(config, "yarn_rm_memory_limit", self.yarn_node_memory_limit),
          yarn_rm_cpu_request: t.objectField(config, "yarn_rm_cpu_request", 0.1),
          yarn_rm_memory_request: t.objectField(config, "yarn_rm_memory_request", 1),
        },
    };

    local s = t.extractStorageParams(config);

    local storage = {
      yarn: {
        yarn_resourcemanager_tmp_storage: t.assembleStorageEntry(config, "yarn_resourcemanager_tmp_storage", s.DiskTmpStorageClass, s.DiskTmpSize, kind="tosdisk"),
        yarn_secondary_tmp_storage: t.assembleStorageEntry(config, "yarn_secondary_tmp_storage", s.DiskTmpStorageClass, s.DiskTmpSize, kind="tosdisk"),
        yarn_historyserver_tmp_storage: t.assembleStorageEntry(config, "yarn_historyserver_tmp_storage", s.DiskTmpStorageClass, s.DiskTmpSize, kind="tosdisk"),
        yarn_nodemanager_tmp_storage: t.assembleStorageEntry(config, "yarn_nodemanager_tmp_storage", s.DiskTmpStorageClass, s.DiskTmpSize, kind="tosdisk"),
        yarn_nodemanager_data_storage: t.assembleStorageEntry(config, "yarn_nodemanager_data_storage", s.DiskDataStorageClass, s.DiskDataSize, kind="tosdisk"),
        yarn_timelineserver_tmp_storage: t.assembleStorageEntry(config, "yarn_timelineserver_tmp_storage", s.DiskTmpStorageClass, s.DiskTmpSize, kind="tosdisk")
      }
    };

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
