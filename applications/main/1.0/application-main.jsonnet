# Copyright 2016 Transwarp Inc. All rights reserved.

# import application function library
local kube = import "../../applib/kube.libsonnet";
local utils = import "../../applib/utils.libsonnet";


function(config={})
  local items = kube.v1.ApplicationInstanceList(config) + {

    local instance_list = config.instance_list,

    items: [
      // Flatten instance properties
      local _instance = config + config.instance_list[i];
      local _instance_settings = utils.objectField(_instance, "instance_settings", {});
      local _instance_configs = utils.objectField(_instance, "configs", {});

      // NOTICE: we have considered `instance_settings` when generating resource `configs`
      // in each application module. Thus the `configs` would overwrite `instance_settings` field.
      local configs = _instance_settings + _instance_configs;

      // All instance properties and settings
      local instance = _instance {
        configs: configs,
      };

      // Create application instance
      local item = kube["apps/v1beta1"].ApplicationInstance(instance);

      // Convert user_config and configs into string
      local annotations = item.metadata.annotations;

      item {
        spec +: {
            configs: std.toString(item.spec.configs)
        }
      }

      // foreach instance
      for i in std.range(0, std.length(config.instance_list) - 1)
    ],
  };
  {
    "application-instance_list.json": items,
  }
