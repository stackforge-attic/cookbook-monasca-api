#require 'zlib'

package 'mon-api' do
  action :upgrade
end

service 'mon-api' do
  action :enable
  provider Chef::Provider::Service::Upstart
end

directory "/var/log/mon-api" do
    recursive true
    owner root
    group root
    mode 0755
    action :create
end

# Create the config file
template '/etc/mon/mon-api-config.yml' do
  action :create
  owner 'root'
  group node[:mon_api][:group]
  mode '640'
  source "service-config.yml.erb"
  variables(
    :creds => creds,
    :keystore_pass => keystore_pass
  )
  notifies :restart, "service[som-api]"
end


credentials = data_bag_item(node[:mon_api][:data_bag], 'mon_credentials')
setting = data_bag_item(node[:mon_api][:data_bag], 'mon_api')

cookbook_file "/etc/ssl/hpmiddleware-keystore.jks" do 
  source creds[:keystore_file]
  owner 'root'
  group node[:mon_api][:group]
  mode '640'
end

cookbook_file "/etc/ssl/hpmiddleware-truststore.jks" do 
  source "hpmiddleware-truststore.jks"
  owner 'root'
  group node[:mon_api][:group]
  mode '640'
end


# Until dropwizard 0.7.0 there is no support for running on a privileged port as an unprivleged user, I work around this via ufw rules
bash "nat 443 to 8080" do
  action :run
  code 'echo -e "*nat\n:PREROUTING ACCEPT [0:0]\n-A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8080\nCOMMIT" >> /etc/ufw/before.rules'
  not_if "grep 'to-port 8080' /etc/ufw/before.rules"
  notifies :restart, "service[ufw]"
end

