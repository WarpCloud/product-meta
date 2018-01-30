{
  application_type: "INCEPTOR",
  application_name: "inceptor1",
  application_version: "2.0",
  user_config: {},
  app_config: {
    "inceptor_master_image": "172.16.1.41:5000/transwarp/inceptor:fixConfd",
    "inceptor_master_cpu_limit": 6.0,
    "inceptor_executor_replicas": 1,
    "LICENSE_ADDRESS": "172.16.1.41:2181",
    "inceptor_executor_memory_limit": 12.0,
    "mysql_image": "172.16.1.41:5000/transwarp/inceptor:fixConfd",
    "inceptor_master_memory_limit": 8.0,
    "metastore_image": "172.16.1.41:5000/transwarp/inceptor:fixConfd",
    "inceptor_executor_cpu_limit": 6.0,
    "inceptor_executor_image": "172.16.1.41:5000/transwarp/inceptor:fixConfd"
  },
  development_mode: true,
}
