# encoding: UTF-8#
#

group node[:monasca_api][:group] do
  action :create
end
user node[:monasca_api][:owner] do
  action :create
  system true
  gid node[:monasca_api][:group]
end

package 'monasca-api' do
  action :upgrade
end

service 'monasca-api' do
  action :enable
  provider Chef::Provider::Service::Upstart
end

directory '/var/log/monasca' do
  recursive true
  owner node[:monasca_api][:owner]
  group node[:monasca_api][:group]
  mode 0775
  action :create
end

creds = data_bag_item(node[:monasca_api][:data_bag], 'credentials')
setting = data_bag_item(node[:monasca_api][:data_bag], 'monasca_api')

# Create the config file
template '/etc/monasca/api-config.yml' do
  action :create
  owner 'root'
  group node[:monasca_api][:group]
  mode '640'
  source 'api-config.yml.erb'
  variables(
    creds: creds,
    setting: setting
  )
  notifies :restart, 'service[monasca-api]'
end

if setting['database-configuration']['database-type'] == 'vertica'

  # Create the directory for the vertica JDBC jar
  directory '/opt/monasca/vertica' do
    recursive true
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end

  # Copy the vertica jdbc jar from /vagrant
  bash 'vertica_jdbc.jar' do
    action :run
    code <<-EOL
    DEST=/opt/monasca/vertica/vertica_jdbc.jar
    if [ ! -s ${DEST} ]; then
       SRC=`ls /vagrant/vertica-jdbc-*.jar`
       if [ $? != 0 ]; then
          echo 'You must place a Vertica JDBC jar in the directory where you do the "vagrant up"' 1>&2
          exit 1
       fi
       cp "$SRC" $DEST
       RC=$?
       if [ $RC != 0 ]; then
          exit $RC
       fi
       chown root:root $DEST
       chmod 0555 $DEST
    fi
    EOL
  end
end
