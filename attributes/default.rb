#
# Cookbook Name:: jetty
# Attributes:: default
#
# Copyright 2010, Opscode, Inc.
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

default["tomcat"]["port"] = 8080
default["tomcat"]["ssl_port"] = 8443
default["tomcat"]["ajp_port"] = 8009
default["tomcat"]["java_options"] = "-Xmx128M -Djava.awt.headless=true"
default["tomcat"]["use_security_manager"] = false
default["tomcat"]["authbind"] = "no"
default["tomcat"]["version"] = "7.0.42"

case platform
when "centos","redhat","fedora"
  set["tomcat"]["user"] = "tomcat"
  set["tomcat"]["group"] = "tomcat"
  set["tomcat"]["root"] = "/usr/local/tomcat"
  set["tomcat"]["home"] = "#{tomcat["root"]}/current"
  set["tomcat"]["base"] = "#{tomcat["root"]}/base"
  set["tomcat"]["config_dir"] = "#{tomcat["base"]}/conf"
  set["tomcat"]["log_dir"] = "#{tomcat["base"]}/logs"
  set["tomcat"]["tmp_dir"] = "#{tomcat["base"]}/temp"
  set["tomcat"]["work_dir"] = "#{tomcat["base"]}/work"
  set["tomcat"]["context_dir"] = "#{tomcat["config_dir"]}/Catalina/localhost"
  set["tomcat"]["webapp_dir"] = "#{tomcat["home"]}"
end