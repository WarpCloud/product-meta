{
  local kube = self,

  matchTosVersion(config={}, version="")::
    if std.objectHas(config, "TosVersion") then
      if config.TosVersion == version then true
      else false
    else if version == "1.2" then true
    else false,

  tosVersionAdapter(config={}, tos1_2="", tos1_5="")::
    if kube.matchTosVersion(config, "1.2") then tos1_2
    else tos1_5,

  haAdapter(config={}, ha="", non_ha="")::
    if config.use_high_availablity then ha
    else non_ha,

  installName(name, config={})::
    if std.length(name) > 0 then name + config.Transwarp_Install_ID else '',

  v1:: {

    local ApiVersion = {
      apiVersion: "v1",
    },

    Metadata(name="", generateName="", config={}): {
      [if std.length(name) > 0 then "name"]: name,
      [if std.length(generateName) > 0 then "generateName"]: generateName,
      [if std.objectHas(config, "Customized_Namespace") && std.length(config.Customized_Namespace) > 0 then "namespace"]: config.Customized_Namespace,
    },

    ReplicationController(name="", generateName="", moduleName="", config={}): ApiVersion {
      local _moduleName = if std.length(moduleName) > 0 then moduleName else if std.length(name) > 0 then name else generateName,
      local _name = if std.length(name) > 0 then name + config.Transwarp_Install_ID else '',

      kind: "ReplicationController",
      metadata: $.v1.Metadata(_name, generateName, config) {
        labels: $.ReservedLabels(_moduleName, config) + $.AppLabels(_moduleName, config),
        # keep this in case in future, we need to add a common annotation
        annotations: {},
      },

      spec: {
        selector: $.ReservedSelector(_moduleName, config),
        template: $.v1.PodTemplate(_moduleName, config),
      },
    },

    ApplicationInstanceList(config={}): ApiVersion {
      kind: "List",
    },

    PdReplicationController(name="", generateName="", moduleName="", pdContainerName="pd", config={}): $.v1.ReplicationController(name, generateName, moduleName, config) {
      local _moduleName = if std.length(moduleName) > 0 then moduleName else if std.length(name) > 0 then name else generateName,
      #            metadata+: {
      #                labels+: {
      #                    [moduleName]: "1"
      #                },
      #            },
      spec+: {
        template+: {
          metadata+: {
            annotations:: super.annotations,
            labels+: {
              #                           [_moduleName + ".install." + config.Transwarp_Install_ID]: "true",
              #                           [_moduleName]: "1",
              "transwarp.pd.pod": "true",
            },
          },
          spec+: {
            containers: [
              $.v1.PodContainer(pdContainerName) {
                args: [
                  "ls",
                ],
                image: std.toString(config.Transwarp_Registry_Server) + "/jenkins/transwarppd:live",
                imagePullPolicy:: super.imagePullPolicy,
              },
            ],
            podDiskSpec: {
              isPersistentDirPod: true,
            },
            restartPolicy: "OnFailure",
          },
        },
      },

    },

    Service(name="", generateName="", moduleName="", selectorModuleName="", config={}): ApiVersion {
      local _moduleName = if std.length(moduleName) > 0 then moduleName else if std.length(name) > 0 then name else generateName,
      local _name = if std.length(name) > 0 then name + config.Transwarp_Install_ID else '',
      local _selectorModuleName = if std.length(selectorModuleName) > 0 then selectorModuleName else _moduleName,

      kind: "Service",
      metadata: $.v1.Metadata(_name, generateName, config) {
        labels: $.ReservedLabels(_moduleName, config) + {
          "k8s-app": _moduleName,
        } + $.AppLabels(_moduleName, config),
        annotations: {},
      },
      spec: {
        selector: $.ReservedSelector(_selectorModuleName, config),
      },
    },

    NodePortService(name="", generateName="", moduleName="", selectorModuleName="", config={}): $.v1.Service(name, generateName, moduleName, selectorModuleName, config) {
      metadata+: {
        labels+: {
          "kubernetes.io/cluster-service": "true",
        },
      },

      spec+: {
        type: "NodePort",
      },
    },

    HeadlessService(name="", generateName="", moduleName="", selectorModuleName="", config={}): $.v1.Service(name, generateName, moduleName, selectorModuleName, config) {
      metadata+: {
        labels+: {
          "kubernetes.io/headless-service": "true",
        },
      },
      spec+: {
        clusterIP: "None",
      },
    },


    DummyService(providesInfo={}, config={}): $.v1.Service(generateName="app-dummy-", moduleName="dummy", config=config) {
      local metaAnnotation = {
        [if std.length(providesInfo) > 0 then "provides"]: providesInfo,
      },

      metadata+: {
        annotations+: {
          [if std.length(metaAnnotation) > 0 then "transwarp.meta"]: std.toString(metaAnnotation),
        },
        labels: $.ReservedLabels("app-dummy", config) + {
          "transwarp.meta": "true",
          "transwarp.svc.scope": "app",
          [if std.objectHasAll(config, "Transwarp_App_Scope") && std.length(config.Transwarp_App_Scope) > 0 then "transwarp.scope"]: config.Transwarp_App_Scope,
        } + config.Transwarp_App_Labels + $.AppLabels("app-dummy", config),
      },
      spec: {
        clusterIP: "None",
        ports: [{
          port: 5000,
          targetPort: 5000,
        }],
        selector: {},
      },
    },

    PodTemplate(moduleName, config): {
      metadata: $.v1.Metadata() {
        annotations: $.ReservedPodAnnotations(config),
        labels: $.ReservedLabels(moduleName, config) + $.AppLabels(moduleName, config),
      },
      spec: {
      },
    },

    PodContainer(name): {
      imagePullPolicy: "Always",
      name: name,
    },

    PersistentDirVolume(name, selector): {
      name: name,
      persistentDir: {
        podSelector: selector,
      },
    },

    PersistentVolumeClaim(name, moduleName, storageConfig={}, config={}): {
      metadata: $.v1.Metadata(name) {
        labels: $.ReservedLabels(moduleName, config) + $.AppLabels(moduleName, config),
        annotations: {
          "volume.beta.kubernetes.io/storage-class": storageConfig.storageClass,
        },
      },
      spec: {
        accessModes: storageConfig.accessModes,
        resources: {
          requests: {
            storage: storageConfig.size,
          },
          [if std.length(storageConfig.limits) > 0 then "limits"]: storageConfig.limits,
        },
      },
    },

    EmptyVolVolume(name, size): {
      name: name,
      emptyVol: {
        mount: {
          size: std.toString(size),
        },
      },
    },

    HostPath(name, path): {
      name: name,
      hostPath: {
        path: path,
      },
    },

    TosDisk(name, storageConfig): {
      name: name,
      tosDisk: {
        name: name,
        storageType: storageConfig.storageClass,
        capability: storageConfig.size,
        accessMode: storageConfig.accessMode,
      },
    },

    HostShareDirVolume(name, path, namespace=""): {
      name: name,
      hostShareDir: {
        path: path,
        [if std.length(namespace) != 0 then "namespace"]: namespace,
      },
    },
    ContainerResources(cpu_request=0, memory_limit=0, cpu_limit=0, memory_request=0): {
      limits: {
        [if memory_limit > 0 then "memory"]: std.toString(memory_limit) + "Gi",
        [if cpu_limit > 0 then "cpu"]: std.toString(cpu_limit),
      },
      requests: {
        [if memory_request > 0 then "memory"]: std.toString(memory_request) + "Gi",
        [if cpu_request > 0 then "cpu"]: std.toString(cpu_request),
      },
    },

    EnvFieldPath(name, path): {
      name: name,
      valueFrom: {
        fieldRef: {
          fieldPath: path,
        },
      },
    },

    Namespace(config={}): ApiVersion {
      local _name = if std.objectHas(config, "name") && std.length(config.name) > 0 then config.name else '',
      local _annotations = if std.objectHas(config, "annotations") && std.length(config.annotations) > 0 then config.annotations else {},

      kind: "Namespace",
      metadata: $.v1.Metadata(_name, '', config) {
        annotations: _annotations,
      },
    },
  },

  "apps/v1beta1":: {
    local ApiVersion = {
      apiVersion: "apps/v1beta1",
    },

    StatefulSet(name="", generateName="", moduleName="", config={}): ApiVersion {
      local _moduleName = if std.length(moduleName) > 0 then moduleName else if std.length(name) > 0 then name else generateName,
      local _installName = kube.installName(name, config),
      kind: "StatefulSet",
      metadata: $.v1.Metadata(_installName, generateName) {
        annotations: {},
        labels: $.ReservedLabels(_moduleName, config) + $.AppLabels(_moduleName, config),
      },
      spec: {
        serviceName: _installName,
        selector: {
          matchLabels: $.ReservedSelector(_moduleName, config),
        },
        template: $.v1.PodTemplate(_moduleName, config),
      },
    },
    ApplicationInstance(config={}): ApiVersion {
      local _moduleName = if std.objectHas(config, "moduleName") && std.length(config.moduleName) > 0 then config.moduleName else '',
      local _name = if std.objectHas(config, "name") && std.length(config.name) > 0 then config.name else '',

      kind: "ApplicationInstance",
      metadata: $.v1.Metadata(_name, '', config) {
        labels: $.ReservedLabels(_moduleName, config) + $.AppLabels(_moduleName, config),
        # keep this in case in future, we need to add a common annotation
        annotations: if std.objectHas(config, "annotations") && std.length(config.annotations) > 0 then config.annotations else {},
      },
      spec: {
        applicationRef: $.ApplicationInstanceRef(_moduleName, config),
        [if std.objectHas(config, "instanceId") && std.length(config.instanceId) > 0 then "instanceId"]: config.instanceId,
        [if std.objectHas(config, "configs") && std.length(config.configs) > 0 then "configs"]: config.configs,
        [if std.objectHas(config, "dependencies") && std.length(config.dependencies) > 0 then "dependencies"]: [
          $.ApplicationInstanceDependencyRef(config.dependencies[i], config)
          for i in std.range(0, std.length(config.dependencies) - 1)
        ],
      },
    },
  },

  "extensions/v1beta1":: {
    local ApiVersion = {
      apiVersion: "extensions/v1beta1",
    },

    Deployment(name="", generateName="", moduleName="", config={}): ApiVersion {
      local _moduleName = if std.length(moduleName) > 0 then moduleName else if std.length(name) > 0 then name else generateName,
      local _name = if std.length(name) > 0 then name + config.Transwarp_Install_ID else '',
      kind: "Deployment",
      metadata: $.v1.Metadata(_name, generateName) {
        annotations: {},
        labels: $.ReservedLabels(_moduleName, config) + $.AppLabels(_moduleName, config),
      },
      spec: {
        selector: {
          matchLabels: $.ReservedSelector(_moduleName, config),
        },
        template: $.v1.PodTemplate(_moduleName, config),
      },
    },

    DeploymentStrategy(config={}):
      if std.type(config) != "object" then
        error ("config must be an object")
      else if std.length(config) == 0 then
        {}
      else if !std.objectHas(config, "type") then
        error ("config does not have type attribute")
      else if config.type == "Recreate" then
        {
          type: "Recreate",
        }
      else if config.type == "RollingUpdate" then
        {
          type: "RollingUpdate",
          rollingUpdate: {
            maxUnavailable: config.rolling_update_configs.max_unavailable,
            maxSurge: config.rolling_update_configs.max_surge,
          },
        }
      else
        error ("invalid configs for Deployment Strategy "),


  },

  instance_selector(config)::
    if std.objectHasAll(config, "Customized_Instance_Selector") && std.length(config.Customized_Instance_Selector) > 0 then
      config.Customized_Instance_Selector
    else {
      "transwarp.install": config.Transwarp_Install_ID,
    },

  ApplicationInstanceRef(name="", config={}):: {
    [if std.length(name) > 0 then "name"]: name,
    [if std.objectHas(config, "version") && std.length(config.version) > 0 then "version"]: config.version,
  },

  ApplicationInstanceDependencyRef(dependency={}, config={}):: {
    local _namespace = if std.objectHas(dependency, "namespace") && std.length(dependency.namespace) > 0 then dependency.namespace
      else if std.objectHas(config, "Customized_Namespace") && std.length(config.Customized_Namespace) > 0 then config.Customized_Namespace
      else "",

    [if std.objectHas(dependency, "moduleName") && std.length(dependency.moduleName) > 0 then "name"]: dependency.moduleName,
    [if std.objectHas(dependency, "name") && std.length(dependency.name) > 0 then "dependencyRef"]: {
      name: dependency.name,
      [if std.length(_namespace) > 0 then "namespace"]: _namespace,
    },
  },

  AppLabels(moduleName, config)::
    if std.objectHas(config, "label") then config.label else {},

  ReservedLabels(moduleName, config):: {
    "transwarp.name": moduleName,
    [if std.objectHas(config, "Transwarp_Alias") && std.length(config.Transwarp_Alias) > 0 then "transwarp.alias"]: config.Transwarp_Alias,
  } + $.instance_selector(config),


  ReservedSelector(moduleName, config):: {
    "transwarp.name": moduleName,
  } + $.instance_selector(config),

  ReservedPodAnnotations(config):: {
    [if std.objectHas(config, "Transwarp_App_Name") && std.length(config.Transwarp_App_Name) > 0 then "transwarp.app"]: config.Transwarp_App_Name,
    [if std.objectHas(config, "Transwarp_Namespace_Owner") && std.length(config.Transwarp_Namespace_Owner) > 0 then "transwarp.namespace.owner"]: config.Transwarp_Namespace_Owner,
    [if kube.matchTosVersion(config, "1.5") then "cni.networks"]: if std.objectHas(config, "Transwarp_Cni_Network") && std.length(config.Transwarp_Cni_Network) > 0 then config.Transwarp_Cni_Network else "overlay",
  },

  NameSpace(config)::
    if std.objectHas(config, "Transwarp_Install_Namespace") && std.length(config.Transwarp_Install_Namespace) > 0 then config.Transwarp_Install_Namespace else "default",

  NSFromSvcMeta(obj)::
    if std.objectHasAll(obj, "metadata") &&
       std.objectHasAll(obj.metadata, "namespace") then
      obj.metadata.namespace
    else "",

  AddrFromRC(rc, suffix="")::
    if std.length(rc) > 0 then (
      if !std.objectHas(rc, "metadata") then
        error ("rc does not have metadata")
      else if !std.objectHas(rc, "spec") then
        error ("rc does not have spec")
      else
        kube.DNSFromRCMeta(rc.metadata, rc.spec.replicas, suffix)
    ) else "",

  AddrFromStatefulSet(statefulSet, suffix="")::
    if std.length(statefulSet) > 0 then (
      if !std.objectHas(statefulSet, "metadata") then
        error ("statefulset does not have metadata")
      else if !std.objectHas(statefulSet, "spec") then
        error ("statefulset does not have spec")
      else
        kube.DNSFromStatefulSetMeta(statefulSet.metadata, statefulSet.spec.replicas, suffix)
    ) else "",

  DNSFromPrefixedId(prefix, config, suffix="svc")::
    std.join(".", [std.toString(prefix) + std.toString(config.Transwarp_Install_ID), std.toString(config.Transwarp_Install_Namespace), if std.length(suffix) > 0 then suffix]),

  DNSFromPod(prefix, config, suffix="")::
    std.join(".", [std.toString(prefix) + std.toString(config.Transwarp_Install_ID), "pod", kube.NameSpace(config), if std.length(suffix) > 0 then suffix]),

  DNSFromRCMeta(rcMeta, replicas, suffix="")::
    if std.type(rcMeta) == "object" && std.length(rcMeta) > 0 then (
      if std.length(rcMeta.name) == 0 || std.length(rcMeta.namespace) == 0 then
        error ("meta does not have name or namespace")
      else
        std.join(",", std.makeArray(replicas, function(i)
          std.join(".", [std.toString(i), rcMeta.name, rcMeta.namespace, "rc", if std.length(suffix) > 0 then suffix])
        ))
    ) else "",

  DNSFromStatefulSetPod(name, id, config={}, suffix="")::
    std.join(".", [kube.installName(name, config) + "-" + std.toString(id), std.toString(config.Transwarp_Install_Namespace), "pod", if std.length(suffix) > 0 then suffix]),

  DNSFromStatefulSetMeta(statefulSetMeta, replicas, suffix="")::
    if std.type(statefulSetMeta) == "object" && std.length(statefulSetMeta) > 0 then (
      local namespace = if std.length(statefulSetMeta.namespace) == 0 then "default" else statefulSetMeta.namespace;
      if std.length(statefulSetMeta.name) == 0 then
        error ("meta does not have name")
      else
        std.join(",", std.makeArray(replicas, function(i)
          std.join(".", [std.join("-", [statefulSetMeta.name, std.toString(i)]), namespace, "pod", if std.length(suffix) > 0 then suffix])))
    ) else "",

  DNSFromNodeSvcMeta(obj={}, ns="namespace", meta="metadata", anno="annotations", name_list="")::
    if std.objectHasAll(obj, meta) &&
       std.objectHasAll(obj[meta], ns) &&
       std.length(obj[meta][ns]) > 0 &&
       std.objectHasAll(obj[meta], anno) &&
       std.objectHasAll(obj[meta][anno], name_list) then
      local nameArr = std.split(obj[meta][anno][name_list], ",");
      local _nl = std.filter(function(x) std.length(x) > 0, nameArr);

      local _ns = obj[meta][ns];

      std.join(",", std.makeArray(std.length(_nl), function(i)
        std.join(".", [_nl[i], _ns, "svc"])
      ))

    else "",

  DNSFromSvcMeta(config, fieldName)::
    if std.objectHas(config, fieldName) && std.length(config[fieldName]) > 0 then (
      if std.length(config[fieldName].name) == 0 || std.length(config[fieldName].namespace) == 0 then
        error ("meta does not have name or namespace")
      else
        config[fieldName].name + "." + config[fieldName].namespace + ".svc"
    ) else "",

  AffinityAnnotations(nodeAffinity={}, podAffinity={}, podAntiAffinity={})::
    {
      "scheduler.alpha.kubernetes.io/affinity": std.toString({
        [if std.length(nodeAffinity) > 0 then "nodeAffinity"]: nodeAffinity,
        [if std.length(podAffinity) > 0 then "podAffinity"]: podAffinity,
        [if std.length(podAntiAffinity) > 0 then "podAntiAffinity"]: podAntiAffinity,
      }),
    },

  NodeAntiAffinityAnnotations(config, moduleName="")::
    local annotations = $.ReservedLabels(moduleName, config) + $.AppLabels(moduleName, config);
    local res =
      {
        requiredDuringSchedulingIgnoredDuringExecution:
          [{
            labelSelector: {
              matchLabels: annotations,
            },
            namespaces: [kube.NameSpace(config)],
            topologyKey: "kubernetes.io/hostname",
          }],
      };
    $.AffinityAnnotations(nodeAffinity={}, podAffinity={}, podAntiAffinity=res),

}
