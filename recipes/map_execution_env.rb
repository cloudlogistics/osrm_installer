package 'git-core'
package 'build-essential'
package 'cmake'
package 'libboost-all-dev'
package 'libbz2-dev'
package 'zlib1g-dev'
package 'libluajit-5.1-dev'
package 'libluabind-dev'
package 'libxml2-dev'
package 'libstxxl-dev'
package 'libosmpbf-dev'
package 'libprotoc-dev'
package 'libtbb-dev'

user = node[:user]
execute "generate ssh skys for #{user}." do
  not_if { ::File.exists?("/home/#{user}/.ssh/id_rsa.pub") }
  Chef::Log.debug("generate ssh skys for #{user}.")

  user user
  creates "/home/#{user}/.ssh/id_rsa.pub"
  command "ssh-keygen -t rsa -q -f /home/#{user}/.ssh/id_rsa -P \"\""
end
