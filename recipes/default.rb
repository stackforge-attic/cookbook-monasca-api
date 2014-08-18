# encoding: UTF-8#
#

package 'mon-api' do
  action :upgrade
end

service 'mon-api' do
  action :enable
  provider Chef::Provider::Service::Upstart
end

directory '/var/log/mon-api' do
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
  source 'mon-service-config.yml.erb'
  variables(
    creds: creds,
    setting: setting
  )
  notifies :restart, 'service[mon-api]'
end

if setting['database-configuration']['database-type'] == 'vertica'

  # Create the directory for the vertica JDBC jar
  directory '/opt/mon/vertica' do
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
    DEST=/opt/mon/vertica/vertica_jdbc.jar
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
