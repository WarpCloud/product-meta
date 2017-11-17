{
   "Customized_Namespace": "default",
   "Develop": false,
   "Transwarp_Install_ID": "",
   "instance_list": [
      {
         "annotations": {
            "application_name": "hdfs1",
            "application_type": "HDFS",
            "user_defined_field": 1
         },
         "configs": {
            "zk_cpu_limit": 2,
            "zk_cpu_request": 0.5,
            "zk_memory_limit": 4,
            "zk_memory_request": 2,
            "zk_storage_config": {
               "accessModes": [
                  "ReadWriteOnce"
               ],
               "limits": {
                  "blkio.throttle.read_iops_device": 100,
                  "blkio.throttle.write_iops_device": 200
               },
               "size": "100Gi",
               "storageClass": "silver"
            }
         },
         "instance_settings": {
            "zk_cpu_limit": 10,
            "Transwarp_Auto_Injected_Volumes": [
               {
                  "kind": "Secret",
                  "selector": {
                     "transwarp.keytab": "clus-11-hdfs-1-0-1c4b-zookeeper"
                  },
                  "volumeName": "keytab"
               }
            ]
         },
         "label": {
            "app.role": "ClusterApp"
         },
         "moduleName": "zookeeper",
         "name": "hdfs1-zookeeper",
         "version": "1.0"
      },
      {
         "annotations": {
            "application_name": "hdfs1",
            "application_type": "HDFS",
            "user_defined_field": 1
         },
         "configs": {
            "hdfs_data_cpu_limit": 2,
            "hdfs_data_cpu_request": 0.5,
            "hdfs_data_memory_limit": 4,
            "hdfs_data_memory_request": 2,
            "hdfs_data_storage": {
               "accessModes": [
                  "ReadWriteOnce"
               ],
               "limits": { },
               "size": "400Gi",
               "storageClass": "silver"
            },
            "hdfs_data_tmp_storage": {
               "accessMode": "ReadWriteOnce",
               "limits": { },
               "size": "100Gi",
               "storageClass": "silver"
            },
            "hdfs_httpfs_cpu_limit": 2,
            "hdfs_httpfs_cpu_request": 0.5,
            "hdfs_httpfs_memory_limit": 4,
            "hdfs_httpfs_memory_request": 2,
            "hdfs_journal_cpu_limit": 2,
            "hdfs_journal_cpu_request": 0.5,
            "hdfs_journal_memory_limit": 4,
            "hdfs_journal_memory_request": 2,
            "hdfs_name_cpu_limit": 4,
            "hdfs_name_cpu_request": 2,
            "hdfs_name_data_storage": {
               "accessModes": [
                  "ReadWriteOnce"
               ],
               "limits": { },
               "size": "400Gi",
               "storageClass": "silver"
            },
            "hdfs_name_memory_limit": 16,
            "hdfs_name_memory_request": 8,
            "hdfs_name_tmp_storage": {
               "accessMode": "ReadWriteOnce",
               "limits": { },
               "size": "100Gi",
               "storageClass": "silver"
            },
            "hdfs_zkfc_cpu_limit": 4,
            "hdfs_zkfc_cpu_request": 2,
            "hdfs_zkfc_memory_limit": 16,
            "hdfs_zkfc_memory_request": 8
         },
         "dependencies": [
            {
               "moduleName": "zookeeper",
               "name": "hdfs1-zookeeper"
            }
         ],
         "instance_settings": {
            "zk_cpu_limit": 10,
            "Transwarp_Auto_Injected_Volumes": [
               {
                  "kind": "Secret",
                  "selector": {
                     "transwarp.keytab": "clus-11-hdfs-1-0-1c4b-hdfs"
                  },
                  "volumeName": "keytab"
               }
            ]
         },
         "moduleName": "hdfs",
         "name": "hdfs1-hdfs",
         "version": "1.0"
      }
   ],
   "instance_settings": { },
   "version": ""
}
