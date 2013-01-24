#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: knife-workstation
# Recipe:: vnc
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

directory "/tmp" do
  mode 01777
end

link '/usr/share/novnc/index.html' do
  to '/usr/share/novnc/vnc_auto.html'
end

directory "/home/#{username}/.vnc" do
  owner "#{username}"
end

template "/home/#{username}/.vnc/xstartup" do
  source "xstartup.erb"
  owner username
  mode 00755
end

execute "chown -R #{username}:#{username} /home/#{username}"

template "/etc/init/vncserver.conf" do
  source "vncserver.upstart.erb"
  mode 00755
end

execute "x11vnc -storepasswd #{node['workstation']['password']} /home/#{username}/.vnc/passwd" do
  user user
  creates "/home/#{user}/.vnc/passwd"
end

directory "/home/#{username}/.config/roxterm.sourceforge.net/Profiles" do
  owner username
  recursive true
  mode "0755"
end

file "/home/#{username}/.config/roxterm.sourceforge.net/Profiles/Default" do
  content <<EOH

[roxterm profile]
font=Inconsolata Medium 16
EOH
  owner username
  mode "0644"
end

directory "/home/#{username}/.fluxbox/backgrounds" do
  recursive true
  mode "0755"
  owner username
end

cookbook_file "/home/#{username}/.fluxbox/backgrounds/background.png" do
  source "background.png"
  owner username
  mode "0644"
end

cookbook_file "/home/#{username}/.fluxbox/init" do
  source "init"
  owner username
  mode "0644"
end

file "/home/#{username}/.fluxbox/overlay" do
  content <<EOH
session.screen0.workspaces: 1
session.screen0.toolbar.tools: clock, prevwindow, nextwindow, iconbar, systemtray
background: centered
background.pixmap: /home/#{username}/.fluxbox/backgrounds/background.png
EOH
  owner username
  mode "0644"
end

directory "/home/#{username}/.config/lxpanel/default/panels" do
  owner username
  mode "0755"
  recursive true
end

file "/home/#{username}/.config/lxpanel/default/config" do
  content <<EOH
[Command]
FileManager=pcmanfm %s
Terminal=roxterm
EOH
  owner username
  mode "0644"
end

cookbook_file "/home/#{username}/.config/lxpanel/default/panels/panel" do
  source "panel"
  owner username
  mode "0644"
end

cookbook_file "/usr/share/applications/sublime.desktop" do
  source "sublime.desktop"
  owner username
  mode "0644"
end

service "vncserver" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true
  ignore_failure true
  action [:enable, :start]
end
