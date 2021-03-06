#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: knife-workstation
# Recipe:: default
#
# Copyright 2012, Opscode, Inc <legal@opscode.com>
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

Chef::Config[:verbose_logging] = false
unless platform?("ubuntu")
  Chef::Log.fatal("#{cookbook_name}::#{recipe_name} is not supported on platform #{node['platform']}")
  raise "Unsupported platform!"
end

username = node['workstation']['username']

file("/etc/profile.d/Z97-byobu.sh") { action :delete }

include_recipe "ii-knife-workstation::user"
include_recipe "ii-knife-workstation::packages"
include_recipe "ii-knife-workstation::ssh"
include_recipe "ii-knife-workstation::editors"
include_recipe "ii-knife-workstation::vnc"
include_recipe "ii-knife-workstation::firefox"

template '/usr/local/bin/new_user_and_org' do
  source 'new_user_and_org.rb.erb'
  mode 0755
end

# org=node['hostname'].split('-').first
# execute "/usr/local/bin/new_user_and_org -u #{org} -p opscode" do
#   creates "/home/#{username}/.chef/#{org}.pem"
#   cwd "/home/#{username}"
#   not_if { org == 'model' } # don't create an org on the model workstation
# end

["/home/#{username}/.chef","/home/#{username}/.chef/bootstrap"].each do |dir|
  directory dir do
    owner username
  end
end

# should this be in a chef_client_via_databags cookbook or maybe  a library?
cc = search('chef',"*:*")
node.normal['chef_client']['version']=cc.map{|v| v['version']}.flatten.uniq.sort.last
node.normal['chef_client']['deb'] = search('chef',"version:#{node['chef_client']['version']} && arch:x86_64 && ubuntu:12.04").first
node.normal['chef_client']['el6'] = search('chef',"version:#{node['chef_client']['version']} && arch:x86_64 && el:6").first
node.normal['chef_client']['el5'] = search('chef',"version:#{node['chef_client']['version']} && arch:x86_64 && el:5").first
template "/home/#{username}/.chef/bootstrap/training.erb" do
  source "bootstrap-training.erb.erb"
end

Chef::Log.info "The workstation is now configured:"

execute "chown -R #{username}:#{username} /home/#{username}"
Chef::Log.info "Login: #{username} Password: #{node['workstation']['password']}"

