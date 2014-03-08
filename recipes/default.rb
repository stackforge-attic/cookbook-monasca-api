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
    owner node[:mon_api][:owner]
    group node[:mon_api][:group]
    mode 0755
    action :create
end

creds = data_bag_item(node[:mon_api][:data_bag], 'mon_credentials')
setting = data_bag_item(node[:mon_api][:data_bag], 'mon_api')

# Create the config file
template '/etc/mon/mon-api-config.yml' do
  action :create
  owner 'root'
  group node[:mon_api][:group]
  mode '640'
  source "mon-service-config.yml.erb"
  variables(
    :creds => creds,
    :setting => setting
  )
  notifies :restart, "service[mon-api]"
end




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



