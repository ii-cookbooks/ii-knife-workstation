# Sets up the default web page

# https://help.ubuntu.com/community/UbuntuLTSP/FirefoxOptimize#General_issues
# http://bazaar.launchpad.net/~ubuntu-branches/ubuntu/precise/ubufox/precise/view/head:/debian/xul-ext-ubufox.js
# However the format seems to be user_pref
#template "/etc/firefox/syspref.js" do

package 'xul-ext-ubufox'

template "/etc/xul-ext/ubufox.js" do
  source 'firefox-prefs.js.erb'
end

# Getting our certificate into most of ubuntu isn't that hard

server_crt = "/usr/local/share/ca-certificates/chefserver.crt"
remote_file server_crt do
  source "http://fileserver.#{node['resolver']['search']}/chefserver.crt"
  not_if {::File.exists? server_crt}
end

package 'libnss3-tools' # provides certutil

execute 'update-ca-certificates' do
  action :nothing
  subscribes :run, "remote_file[#{server_crt}]"
end

# But getting a certificate into firefox is a pain

ff_def_profile = '/usr/lib/firefox/defaults/profile'
directory ff_def_profile

execute 'create ff ca db' do
  command "certutil -A -n chef.#{node['resolver']['search']} -d #{ff_def_profile} -t 'CTu,,' -u 'c' -a -i #{server_crt} ; certutil -A -n chef.training -d #{ff_def_profile} -t 'CTu,,' -u 'c' -a -i #{server_crt}"
  creates "#{ff_def_profile}/cert8.db"
end

%w{ cert8.db key3.db secmod.db }.each do |certdb|
  # these files must be readable for user to pick them up
  file ::File.join(ff_def_profile,certdb) do
    mode 0644
  end
end

