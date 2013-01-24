#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: knife-workstation
# Recipe:: editors
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

cookbook_file "/etc/vim/vimrc.local" do
  source "vimrc.local"
  mode 00644
end

cookbook_file "/etc/motd.tail" do
  source "motd.tail"
  mode 00644
end

cookbook_file "/home/#{username}/.bashrc" do
  source "user.bashrc"
  mode 00644
end

sbl_tar = File.join(Chef::Config[:file_cache_path], "SublimeText2.tar.bz2")

remote_file sbl_tar do
  arch = node['kernel']['machine'] =~ /x86_64/ ? "%20x64" : ""
  source "http://fileserver/Sublime%20Text%202.0.1#{arch}.tar.bz2"
  not_if { ::File.symlink?("/opt/SublimeText2") }
end

execute "install sublimetext2" do
  command <<-EOH
tar -jxf #{sbl_tar} -C /opt
EOH
end

link "/opt/SublimeText2" do
  to "/opt/Sublime\ Text\ 2"
end

file "/etc/profile.d/sublime_path.sh" do
  content "export PATH=$PATH:/opt/SublimeText2\n"
  mode 00644
end

directory "/home/#{username}/.config/sublime-text-2/Packages/User" do
  recursive true
  owner "#{username}"
end

package "ttf-inconsolata"

cookbook_file "/home/#{username}/.config/sublime-text-2/Packages/User/Preferences.sublime-settings" do
  source "Preferences.sublime-settings"
  owner "#{username}"
end

cookbook_file "/home/#{username}/.config/sublime-text-2/Packages/User/Ruby.sublime-settings" do
  source "Ruby.sublime-settings"
  owner "#{username}"
end
