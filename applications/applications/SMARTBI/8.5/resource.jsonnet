# Copyright 2016 Transwarp Inc. All rights reserved.
local t = import "../../../applib/utils.libsonnet";

{
  /*
   * Define resource metrics for each module
   */
  __moduleResourceRaw(moduleName, config={})::
    local Debug_Request = t.objectField(config, "Develop", false);

    local resource = {
      smartbi:
        {
          smartbi_tomcat_cpu_limit: t.objectField(config, "smartbi_cpu_limit", 2),
          smartbi_tomcat_memory_limit: t.objectField(config, "smartbi_tomcat_memory_limit", 4),
          smartbi_tomcat_cpu_request: t.objectField(config, "smartbi_tomcat_cpu_request", 0.1),
          smartbi_tomcat_memory_request: t.objectField(config, "smartbi_tomcat_memory_request", 1),
          smartbi_mysql_cpu_limit: t.objectField(config, "smartbi_mysql_cpu_limit", 2),
          smartbi_mysql_memory_limit: t.objectField(config, "smartbi_mysql_memory_limit", 4),
          smartbi_mysql_cpu_request: t.objectField(config, "smartbi_mysql_cpu_request", 0.1),
          smartbi_mysql_memory_request: t.objectField(config, "smartbi_mysql_memory_request", 1),
        },
    };

    local storage = {};

    // Return storage and resource specification
    {
      storage: if std.objectHas(storage, moduleName) then storage[moduleName] else {},
      resource: if std.objectHas(resource, moduleName) then resource[moduleName] else {},
    },

}
