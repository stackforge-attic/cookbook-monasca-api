# encoding: UTF-8#
#
default[:som_api][:firewall][:rules] = [
  https: {
    port: '443',
    protocol: 'tcp'
  },
  https_8080: {
    port: '8080',
    protocol: 'tcp'
  },
  http_8081: {
    port: '8081',
    protocol: 'tcp'
  }
]
