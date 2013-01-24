#
# Author:: Joshua Timberman <joshua@opscode.com>
# Cookbook Name:: knife-workstation
# Recipe:: packages
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

pkgs = %w{
language-pack-en
dictionaries-common
whois
ack-grep
git
subversion
mercurial
bzr
unzip
vim-gtk
emacs23
emacs-goodies-el
fluxbox
firefox
roxterm
ttf-inconsolata
tightvncserver
gedit
lxpanel
x11vnc
novnc
libxml2-dev
libxslt-dev
make
g++
}

rmpkgs = %w{libruby1.8 ruby1.8 libruby ruby}

execute "apt-get update" do
  ignore_failure true
end

execute "apt-get --force-yes -y install #{pkgs.join(" ")}" do
  not_if { File.exists?("/root/packages_installed") }
  notifies :create, "file[/root/packages_installed]" 
end

file "/root/packages_installed" do
  content "yep"
  action :nothing
end

rmpkgs.each do |p|
  package p do
    action :purge
  end
end

# we use this to create new orgs/users
%w{ mechanize knife-windows }.each do |knifegem|
  gem_package knifegem do
    gem_binary '/opt/chef/embedded/bin/gem'
    options '--no-rdoc --no-ri'
  end
end
