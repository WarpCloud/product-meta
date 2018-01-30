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
local utils = import "../utils.libsonnet";

std.assertEqual(utils.numTCU("c", 4, 8), 1) &&
std.assertEqual(utils.numTCU("m", 2, 16), 1) &&
std.assertEqual(utils.numTCU("s", 2, 8, 128), 1) &&
std.assertEqual(utils.numTCU("s", 4, 16, 128), 2) &&

std.assertEqual(utils.raRange(4, 1, 8), 4) &&
std.assertEqual(utils.raRange(4, 5, 8), 5) &&
std.assertEqual(utils.raRange(4, 1, 2), 2) &&

std.assertEqual(utils.isDevelopmentMode({development_mode: true}), true) &&
std.assertEqual(utils.isDevelopmentMode({}), false) &&
std.assertEqual(utils.isDevelopmentMode({development_mode: "true"}), true) &&
std.assertEqual(utils.isDevelopmentMode({development_mode: "tRue"}), true) &&
std.assertEqual(utils.isDevelopmentMode({development_mode: "True"}), true) &&
std.assertEqual(utils.isDevelopmentMode({development_mode: "false"}), false) &&
std.assertEqual(utils.isDevelopmentMode({development_mode: "false"}), false) &&
std.assertEqual(utils.isDevelopmentMode({Develop: true}), false) &&

std.assertEqual(utils.getUnifiedInstanceSettings({
  development_mode: true
})["Develop"], true) &&
std.assertEqual(utils.getUnifiedInstanceSettings({
  development_mode: true,
  app_config: {
    Develop: false,
  }
})["Develop"], true) &&
std.assertEqual(utils.getUnifiedInstanceSettings({
  development_mode: false,
  app_config: {
    Develop: true,
  }
})["Develop"], false) &&
std.assertEqual(utils.getUnifiedInstanceSettings({
  development_mode: false,
  app_config: {
    Develop: false,
  }
})["Develop"], false) &&
std.assertEqual(utils.getUnifiedInstanceSettings({
  Develop: true,
})["Develop"], false) &&

true
