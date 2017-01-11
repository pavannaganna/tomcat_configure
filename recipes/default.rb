#
# Cookbook:: tomcat_configure
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
tomcat_service_name = 'tomcat8'
tomcat_user_group = "tomcat_#{tomcat_service_name}"
include_recipe 'java'

# Install tomcat 8.0.36 version and configures required user and group
tomcat_install tomcat_service_name do
  version '8.0.36'
  exclude_docs false
  exclude_examples false
  exclude_manager false
end

# Creates a directory to store the ssl certs and key
directory '/usr/local/ssl/' do
  owner tomcat_user_group
  group tomcat_user_group
  mode 00755
  recursive true
  action :create
end

# Creates server.crt file and server.pem - this file is a self signed certificate.
# See more at https://www.linux.com/learn/creating-self-signed-ssl-certificates-apache-linux
# For APR implementation, see https://tomcat.apache.org/tomcat-6.0-doc/apr.html
cookbook_file '/usr/local/ssl/server.crt' do
  source 'server.crt'
  owner tomcat_user_group
  group tomcat_user_group
  mode 00777
end

cookbook_file '/usr/local/ssl/server.pem' do
  source 'server.pem'
  owner tomcat_user_group
  group tomcat_user_group
  mode 00777
end

# Creates (actually copy) the keystore file for JSSE implementation in tomcat
# JSSE is currently implemented using this cookbook.
cookbook_file '/usr/local/ssl/tomcat' do
  source 'tomcat'
  owner tomcat_user_group
  group tomcat_user_group
  mode 00644
end

tomcat_service tomcat_service_name do
  action [:enable, :start]
end

# Creates server.xml file with JSSE configs
template "/opt/tomcat_#{tomcat_service_name}/conf/server.xml" do
  source 'server.xml.erb'
  owner tomcat_user_group
  group tomcat_user_group
  mode 00744
  notifies :restart, "tomcat_service[#{tomcat_service_name}]", :delayed
end
