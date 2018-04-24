# Copyright 2016 Transwarp Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
local resource = import "../resource.jsonnet";
local hdfs_resource = resource.moduleResource("hdfs");
local hdfs_tcu = resource.moduleTCU("hdfs");
local zookeeper_resource = resource.moduleResource("zookeeper");
local zookeeper_tcu = resource.moduleTCU("zookeeper");

std.assertEqual(std.objectHas(hdfs_resource, "configs"), true) &&
std.assertEqual(hdfs_tcu, {"c": 3, "m": 6, "s": 6}) &&
std.assertEqual(std.objectHas(zookeeper_resource, "configs"), true) &&
std.assertEqual(zookeeper_tcu, {"c": 0.5, "m": 1, "s": 1}) &&
true
