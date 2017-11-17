# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  local _zookeeperModuleName = "zookeeper",
  local _filebeatModuleName = "filebeat",
  local _logstashModuleName = "logstash",
  local _milanoPortalModuleName = "milano-portal",
  local _kafkaManagerModuleName = "kafka-manager",

  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      [_filebeatModuleName]:
        if Debug_Request then
          {
            filebeat_cpu_limit: 0.5,
            filebeat_memory_limit: 1,
            filebeat_cpu_request: self.filebeat_cpu_limit,
            filebeat_memory_request: self.filebeat_memory_limit,
          }
        else
          {
            filebeat_cpu_limit: t.objectField(config, "filebeat_cpu_limit", 1),
            filebeat_memory_limit: t.objectField(config, "filebeat_memory_limit", 2),
            filebeat_cpu_request: t.objectField(config, "filebeat_cpu_request", self.filebeat_cpu_limit),
            filebeat_memory_request: t.objectField(config, "filebeat_memory_request", self.filebeat_memory_limit),
          },
      [_logstashModuleName]:
        if Debug_Request then
          {
            logstash_cpu_limit: 0.5,
            logstash_memory_limit: 1,
            logstash_cpu_request: self.logstash_cpu_limit,
            logstash_memory_request: self.logstash_memory_limit,
          }
        else
          {
            local cpu_limit = resource[_filebeatModuleName].filebeat_cpu_limit,
            local memory_limit = resource[_filebeatModuleName].filebeat_memory_limit,

            logstash_cpu_limit: t.objectField(config, "logstash_cpu_limit", cpu_limit),
            logstash_memory_limit: t.objectField(config, "logstash_memory_limit", memory_limit),
            logstash_cpu_request: t.objectField(config, "logstash_cpu_request", self.logstash_cpu_limit),
            logstash_memory_request: t.objectField(config, "logstash_memory_request", self.logstash_memory_limit),
          },
      [_kafkaManagerModuleName]:
        if Debug_Request then
          {
            kafka_manager_cpu_limit: 0.5,
            kafka_manager_memory_limit: 1,
            kafka_manager_cpu_request: self.kafka_manager_cpu_limit,
            kafka_manager_memory_request: self.kafka_manager_memory_limit,
          }
        else
          {
            local cpu_limit = resource[_filebeatModuleName].filebeat_cpu_limit,
            local memory_limit = resource[_filebeatModuleName].filebeat_memory_limit,

            kafka_manager_cpu_limit: t.objectField(config, "kafka_manager_cpu_limit", cpu_limit),
            kafka_manager_memory_limit: t.objectField(config, "kafka_manager_memory_limit", memory_limit),
            kafka_manager_cpu_request: t.objectField(config, "kafka_manager_cpu_request", self.kafka_manager_cpu_limit),
            kafka_manager_memory_request: t.objectField(config, "kafka_manager_memory_request", self.kafka_manager_memory_limit),
          },
      [_milanoPortalModuleName]:
        if Debug_Request then
          {
            milano_portal_cpu_limit: 0.5,
            milano_portal_memory_limit: 1,
            milano_portal_cpu_request: self.milano_portal_cpu_limit,
            milano_portal_memory_request: self.milano_portal_memory_limit,
          }
        else
          {
            local cpu_limit = resource[_filebeatModuleName].filebeat_cpu_limit,
            local memory_limit = resource[_filebeatModuleName].filebeat_memory_limit,

            milano_portal_cpu_limit: t.objectField(config, "milano_portal_cpu_limit", cpu_limit),
            milano_portal_memory_limit: t.objectField(config, "milano_portal_memory_limit", memory_limit),
            milano_portal_cpu_request: t.objectField(config, "milano_portal_cpu_request", self.milano_portal_cpu_limit),
            milano_portal_memory_request: t.objectField(config, "milano_portal_memory_request", self.milano_portal_memory_limit),
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
      [_filebeatModuleName]: [
        "filebeat_cpu_limit",
      ],
      [_logstashModuleName]: [
        "logstash_cpu_limit",
      ],
      [_kafkaManagerModuleName]: [
        "kafka_manager_cpu_limit",
      ],
      [_milanoPortalModuleName]: [
        "milano_portal_cpu_limit",
      ],
    };

    local mem_metrics = {
      [_filebeatModuleName]: [
        "filebeat_memory_limit",
      ],
      [_logstashModuleName]: [
        "logstash_memory_limit",
      ],
      [_kafkaManagerModuleName]: [
        "kafka_manager_memory_limit",
      ],
      [_milanoPortalModuleName]: [
        "milano_portal_memory_limit",
      ],
    };

    local unifiedConfig = t.getUnifiedInstanceSettings(config);
    t.calculateModuleTCU(moduleName, unifiedConfig, $.__moduleResourceRaw,
      cpu_metrics, mem_metrics),
}
