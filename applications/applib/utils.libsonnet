# Copyright 2016 Transwarp Inc. All rights reserved.

local kube = import "kube.libsonnet";
local app = import "app.libsonnet";

{
  /*
   * Get `filed_name` of object or default value
   */
  objectField(obj, field_name, default)::
    local has_field = std.objectHas(obj, field_name);
    local field_value = if has_field then obj[field_name] else null;
    if field_value == null then default
    else if std.type(field_value) == "boolean" ||
            std.type(field_value) == "number" ||
            std.type(field_value) == "function" then
        field_value
    else if std.length(field_value) > 0 then field_value
    else default,

  parseNumber(str)::
    local array = std.split(str, '.');
    if std.length(array) == 1 then
        std.parseInt(array[0])
    else if std.length(array) == 2 && std.length(array[1]) >= 1 then
        local digits_after_point = std.length(array[1]);
        std.parseInt(array[0]) + std.parseInt(array[1])/std.pow(10,digits_after_point)
    else 0,

  diskSizeInByte(size)::
    local isDigitOrPoint(ch) = (std.codepoint(ch) >= 48 && std.codepoint(ch) <=57) || std.codepoint(ch) == 46;
    local digits(ch) = if isDigitOrPoint(ch) then ch else "";
    local unit(ch) = if isDigitOrPoint(ch) then "" else ch;

    local _size = self.parseNumber(std.join("", std.map(digits, size)));
    local _unit = std.join("", std.map(unit, size));
    local toPower(unit) =
        if std.startsWith(unit, "G") || std.startsWith(unit, "g")
            then 1024 * 1024 * 1024
        else if std.startsWith(unit, "M") || std.startsWith(unit, "m")
            then 1024 * 1024
        else if std.startsWith(unit, "K") || std.startsWith(unit, "k")
            then 1024
        else if std.startsWith(unit, "B") || std.startsWith(unit, "b")
            then 1
        else 0;
    std.floor(_size * toPower(_unit)),

  /**
   * Check the value of a field is true or false
   */
  trueOrFalse(object, field)::
    local value = $.objectField(object, field, null);
    if value != null then
      if value == true || value == "true" || value == "TRUE" || value == "True" then
        true
      else
        false
    else
      false,

  /**
   * Check if the dev mode is enabled
   */
  isDevelopmentMode(config={}, key="development_mode")::
    if std.objectHas(config, key) then
      local val = config[key];
      if std.type(val) == "boolean" && val == true then
        true
      else if std.type(val) == "string" && app.strLower(val) == "true" then
        true
      else
        false
    else
      false,

  /**
   * Create instance profile given specific application.
   * @param moduleName: the kubernetes module
   * @param config: an object of application settings with
   *   required `application_name`, `application_type`, as well as
   *   optional `user_config`, `app_config`
   */
  createInstance(moduleName, config={}, default_version="")::
    local name = config.application_name;
    local type = config.application_type;

    local user_config = $.objectField(config, "user_config", {});
    local app_config = $.objectField(config, "app_config", {});
    local instance_config = $.objectField(config, "instance_config", {});
    local ins_config = $.objectField(instance_config, moduleName, {});
    local label = if std.objectHas(config, "label") && std.length(config.label) > 0 then {
        "label": config.label
    } else {};

    // Check instance version
    local instance_versions = $.objectField(app_config, "instance_versions", {});
    local version = $.objectField(instance_versions, moduleName, default_version);

    {
      moduleName: moduleName,
      name: name + "-" + moduleName,
      version: version,
      # TODO generate id by kubernetes instead of client
      # instanceId: name + "-" + moduleName,
      annotations: {
        application_type: type,
        application_name: name
      } + user_config,
      instance_settings: app_config + ins_config,
    } + label,

  /**
   * Get default instance list settings
   */
  getDefaultSettings(config={})::
    {
      version: "",
      Develop: $.isDevelopmentMode(config),

      Transwarp_Install_ID: "",
      Customized_Namespace: "default",

      instance_list: [],
      instance_settings: {},
    },

  /*
   * Generate unified instance settings.
   */
  getUnifiedInstanceSettings(config={})::
    local _default = $.getDefaultSettings(config);
    local _dev = $.isDevelopmentMode(config);
    local app_config = $.objectField(config, "app_config", {});

    _default + app_config + { Develop: _dev },

  /*
   * The range algorithm to determine resource allocation.
   * @reference: the referred field to calculate the value
   * @min the lower bound of requested value
   * @max the upper bound of requested value
   */
  raRange(reference, min, max)::
    std.min(max, std.max(min, reference)),

  /*
   * Calculate the count of TCU given resources.
   * Three types of TCP supported:
   *   Computing-oriented, Memory-oriented, and Storage-oriented
   */
  numTCU(type="c", cpu_num=0, mem_gb=0, ssd_gb=0, disk_gb=0)::
    // Computing-oriented
    local computing_cpu_unit = 4;
    local computing_mem_unit = 8;
    // Memory-oriented
    local memory_cpu_unit = 2;
    local memory_mem_unit = 16;
    // Storage-oriented:
    local storage_cpu_unit = 2;
    local storage_mem_unit = 8;
    local storage_ssd_unit = 128;
    local storage_disk_unit = 128;

    local tcu_num =
      // Computing-oriented
      if app.strLower(type) == "c" then
        std.max(cpu_num / computing_cpu_unit, mem_gb / computing_mem_unit)
      // Memory-oriented
      else if app.strLower(type) == "m" then
        std.max(cpu_num / memory_cpu_unit, mem_gb / memory_mem_unit)
      // Storage-oriented
      else if app.strLower(type) == "s" then
      std.max(
        disk_gb / storage_disk_unit,
          std.max(
            ssd_gb / storage_ssd_unit,
            std.max(cpu_num / storage_cpu_unit, mem_gb / storage_mem_unit)
          )
      );
    tcu_num,

  sum:: function(x, y) x + y,

  /*
   * Calculate the sum of a numeric array
   */
  arraySum(arr)::
    std.foldl($.sum, arr, 0),


  /*
   * A shortcut to process module TCU calculation.
   * @module_name: the instance to calculate TCU
   * @config: the application configs
   * @func: the function to calculate raw resource {storage: {}, resource: {]}}
   */
  calculateModuleTCU(module_name, config, func, cpu_metrics={}, mem_metrics={}, ssd_metrics={}, disk_metrics={})::
    local name = module_name;
    local module = func(name, config);

    local cpu_values =
      if std.objectHas(cpu_metrics, name) then
        [module.resource[i] for i in cpu_metrics[name] if std.objectHas(module.resource, i)]
      else
        [];
    local total_cpu = if std.length(cpu_values) > 0 then $.arraySum(cpu_values) else 0;

    local mem_values =
      if std.objectHas(mem_metrics, name) then
        [module.resource[i] for i in mem_metrics[name] if std.objectHas(module.resource, i)]
      else
        [];
    local total_mem = if std.length(mem_values) > 0 then $.arraySum(mem_values) else 0;

    local ssd_values =
      if std.objectHas(ssd_metrics, name) then
        [module.resource[i] for i in ssd_metrics[name] if std.objectHas(module.resource, i)]
      else
        [];
    local total_ssd = if std.length(ssd_values) > 0 then $.arraySum(ssd_values) else 0;

    local disk_values =
      if std.objectHas(disk_metrics, name) then
        [module.resource[i] for i in disk_metrics[name] if std.objectHas(module.resource, i)]
      else
        [];
    local total_disk = if std.length(disk_values) > 0 then $.arraySum(disk_values) else 0;

    # Return three types of TCU for each module
    {
      c: $.numTCU("c", total_cpu, total_mem, total_ssd, total_disk),
      m: $.numTCU("m", total_cpu, total_mem, total_ssd, total_disk),
      s: $.numTCU("s", total_cpu, total_mem, total_ssd, total_disk),
    },

  /*
   * A unified interface to extract storage settings.
   */
  extractStorageParams(config, normal_size="512Gi", data_size="512Gi", log_size="256Gi",
    tmp_size="256Gi", ssd_size="256Gi", read_iops=0, write_iops=0
  )::
    {
      DiskNormalSize: $.objectField(config, "DiskNormalSize", normal_size),
      DiskDataSize: $.objectField(config, "DiskDataSize", data_size),
      DiskLogSize: $.objectField(config, "DiskLogSize", log_size),
      DiskTmpSize: $.objectField(config, "DiskTmpSize", tmp_size),

      ReadIOPS: $.objectField(config, "ReadIOPS", read_iops),
      WriteIOPS: $.objectField(config, "WriteIOPS", write_iops),

      StorageClass: $.objectField(config, "StorageClass", "silver"),

      SSDSize: $.objectField(config, "SSDSize", ssd_size),
      SSDStorageClass: $.objectField(config, "SSDStorageClass", "golden"),
    },

  /*
   * Assemble storage setting entry for specific field.
   */
  assembleStorageEntry(config, field_name, storageClass="", size="",
    read_iops=0, write_iops=0, kind="pvc"
  )::
    // PVC or TOS_DISK?
    local accessModeName = if kind == "pvc" then "accessModes" else "accessMode";
    local accessModeValue = if kind == "pvc" then ["ReadWriteOnce"] else "ReadWriteOnce";
    local default = {
      storageClass: storageClass,
      size: size,
      [accessModeName]: accessModeValue,
      limits: {
        "blkio.throttle.read_iops_device": read_iops,
        "blkio.throttle.write_iops_device": write_iops,
      },
    };
    $.objectField(config, field_name, default),
}
