{
  application_type: "HDFS",
  application_name: "hdfs1",
  application_version: "1.0",
  user_config: {},
  app_config: {
    /*"hdfs_name_cpu_limit": 20,*/
  },
  instance_config: {
    "hdfs": {
      "Transwarp_Auto_Injected_Volumes": [
          {
            "volumeName": "keytab",
            "kind": "Secret",
            "selector": {
                 "transwarp.keytab": "clus-11-hdfs-1-0-1c4b-hdfs"
            }
          }
      ],
    },
    "zookeeper": {
      "Transwarp_Auto_Injected_Volumes": [
          {
            "volumeName": "keytab",
            "kind": "Secret",
            "selector": {
                 "transwarp.keytab": "clus-11-hdfs-1-0-1c4b-hdfs"
            }
          }
      ],
    },
  },
}
