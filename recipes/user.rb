#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: knife-workstation
# Recipe:: user
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

username = node['workstation']['username']

user username do
  home "/home/#{username}"
  shell "/bin/bash"
  comment username.capitalize
  supports :manage_home => true
end


file "/etc/sudoers.d/#{username}" do
  content "#{username} ALL=(ALL:ALL) NOPASSWD: ALL"
  mode 0440
end

group "sudo" do
  members username
  action :modify
  append true
end
