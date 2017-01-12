################### RUN TASK ON SPECIFIC HOST ##########

def with_role(role, &block)
  original, ENV['HOSTS'] = ENV['HOSTS'],
                           find_servers(roles: role).map{|d| d.host}.join(",")
  begin
    yield
  ensure
    ENV['HOSTS'] = original
  end
end

################### CONFIGURE SERVER ###################

server '35.165.243.175', :map_generation_env,  primary: true #
server '35.167.70.43', :map_execution_env

set :user, 'ubuntu'

# set :branch, 'staging'
set :rails_env, 'staging'

set :application, "osm_installer"
set :scm, :none

set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true


############## ROUNDSMAN FINE TUNING ###################

set :chef_version, '~> 12.6.0'

set :stream_roundsman_output, false # todo check why is this needed
set :debug_chef, true

set :ruby_version, "2.2.2"
set :care_about_ruby_version, true
set :group_writable, false
set :cookbooks_directory,  "./config/cookbooks"
# set_default :ruby_install_dir, "/usr/local"


set :run_list, %w(
  recipe[apt]
  recipe[osrm_installer::default]
)

set :ruby_install_script do
  %Q{
          set -e
          cd #{roundsman_working_dir}
          rm -rf ruby-build
          git clone -q https://github.com/sstephenson/ruby-build.git
          cd ruby-build
          ./install.sh
          CONFIGURE_OPTS='--disable-install-rdoc' ruby-build #{fetch(:ruby_version)} #{fetch(:ruby_install_dir)}
          gem install bundler
          gem install specific_install
          gem specific_install -l 'git://github.com/ataka/rubygems-format-dummy.git'
  }
end

set :repository, 'foo'

namespace :mana do
  desc 'install all dependant cookbooks'
  task :berks_install do
    run_locally "bundle exec berks install && bundle exec berks vendor #{fetch(:cookbooks_directory)}"
  end

  desc 'Complete update of all software'
  task :default do
    if roundsman.install.install_ruby?
      abort "Node is not boostrapped yet. Please run 'cap mana:setup' instead"
    end
    install
    # deploy.migrations
  end

  desc 'Bootstrap chef and ruby'
  task :bootstrap do
    roundsman.install.default
    roundsman.chef.install
  end

  desc 'install dependencies and run osrm on map_generation_env'
  task :map_generation_env_setup do
    with_role :map_generation_env do
      roundsman.chef.default
      # fix https://github.com/iain/roundsman/issues/26
      variables.keys.each { |k| reset! k }
    end
  end

  desc 'install dependencies on run env and download generated public key'
  task :map_execution_env_prepare do
    with_role :map_execution_env do
      roundsman.run_list "recipe[osrm_installer::map_execution_env]"
      download("/home/#{fetch(:user)}/.ssh/id_rsa.pub", "./id_rsa.pub")
    end
  end

  desc 'upload generated public key to map_generation_env'
  task :map_generation_env_copy_key do
    map_execution_env_host = find_servers(roles: :map_execution_env).first.host

    with_role :map_generation_env do
      upload("./id_rsa.pub", "/home/#{fetch(:user)}/#{map_execution_env_host}.pub")
      run "grep -q -F '#{map_execution_env_host}' /home/#{fetch(:user)}/.ssh/authorized_keys || printf \"\\n##{map_execution_env_host} \\n$(cat /home/#{fetch(:user)}/#{map_execution_env_host}.pub)\" >> /home/#{fetch(:user)}/.ssh/authorized_keys"
    end
  end

  desc 'syncs generated map and starts osrm-routed'
  task :map_execution_env_setup do
    map_generation_env_host = find_servers(roles: :map_generation_env).first.host

    with_role :map_execution_env do
      ['osrm', 'osrm-data'].each do |folder|
        run "rsync -avhW --no-compress --progress -e 'ssh' --rsync-path='sudo rsync' ubuntu@#{map_generation_env_host}:/opt/#{folder} ~/"
        run "sudo mv -f ~/#{folder} /opt/"
      end
      roundsman.run_list "recipe[osrm_installer::setup_routed]"
    end
  end

  desc 'Show install log'
  task :log do
    sudo "cat /tmp/roundsman/cache/chef-stacktrace.out"
  end

  desc 'Complete setup'
  task :setup  do
    berks_install
    upgrade
    bootstrap
    map_generation_env_setup
    map_execution_env_prepare
    map_generation_env_copy_key
    map_execution_env_setup
  end

  desc 'Upgrade software'
  task :upgrade do
    sudo "DEBIAN_FRONTEND=noninteractive #{fetch(:package_manager)} -yq update"
    sudo "DEBIAN_FRONTEND=noninteractive #{fetch(:package_manager)} -yq upgrade"
  end

  set :ssh_login_options, '-L 3737:localhost:3737' # forward monit status server port

  desc "Open SSH connection to server"
  task :ssh do
    host = roles[:app].servers.first # silly approach
    exec "ssh #{ssh_login_options} #{fetch(:user)}@#{host}"
  end

  def sudo_runner
    (exists? :runner) ? (sudo as: runner) : ''
  end
end
