#
# Cookbook Name:: tomcat
# Recipe:: default
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
#

include_recipe "java"

version = node['tomcat']['version']
filename = "apache-tomcat-#{version}"
deployDir = "/usr/local/tomcat"

group "tomcat" do
  action :create
  append true
  gid 1000
end

user "tomcat" do
  comment "tomcat"
  uid 1000
  gid "tomcat"
  home "#{node.tomcat.root}"
  shell "/bin/bash"
end

directory "#{node.tomcat.root}" do
  owner "tomcat"
  group "tomcat"
  mode 00775
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/#{filename}.zip" do
  source "http://ftp.meisei-u.ac.jp/mirror/apache/dist/tomcat/tomcat-7/v#{version}/bin/#{filename}.zip"
  not_if do
    ::File.exists?("#{Chef::Config[:file_cache_path]}/#{filename}.zip") or
    ::File.exists?("#{node.tomcat.root}/releases/#{filename}")
  end
end

bash "install tomcat" do
  user "root"
  cwd "#{node.tomcat.root}"
  flags "-x -e"
  code <<-EOH
  mkdir -p releases
  unzip -q #{Chef::Config[:file_cache_path]}/#{filename}.zip -d releases
  ln -f -s releases/#{filename} current
  chmod ug+x current/bin/*.sh
  chown -R tomcat.tomcat #{node.tomcat.root}
  EOH
  not_if do
    ! ::File.exists?("#{Chef::Config[:file_cache_path]}/#{filename}.zip") or
    ::File.exists?("#{node.tomcat.root}/releases/#{filename}")
  end
end

bash "setup tomcat environment" do
  user "tomcat"
  group "tomcat"
  cwd "#{node.tomcat.root}"
  flags "-x -e"
  code <<-EOH
  mkdir -p base
  cp -rp current/{conf,lib,logs,temp,work} base
  mkdir -p base/releases/v0.0.1
  cd base
  ln -s releases/v0.0.1 webapps
  cd ..
  cp -rp current/webapps/* base/webapps/
  chown -R tomcat.tomcat #{node.tomcat.root}
  EOH
  not_if do
    ::File.exists?("#{node.tomcat.root}/base/webapps")
  end
end

case node["platform"]
when "centos","redhat","fedora"
  template "/etc/init.d/tomcat" do
    source "tomcat7.erb"
    owner "root"
    group "root"
    mode "0755"
  end
end

template "#{node.tomcat.config_dir}/server.xml" do
  source "server.xml.erb"
  owner "tomcat"
  group "tomcat"
  mode "0644"
end

service "tomcat" do
  service_name "tomcat"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  end
  action [:enable, :start]
end

# open iptables port
iptables_rule "tomcat"
