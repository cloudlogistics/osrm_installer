#this
server 'api.distance-source.gocloudlogistics.com', :web, :app, :db,  primary: true

set :user, 'ubuntu'

# set :branch, 'staging'
set :rails_env, 'staging'

set :application, "osm_installer"
set :repository,  "set your repository location here"

set :scm, :none
# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "ubuntu"                          # Your HTTP server, Apache/etc
# role :app, "ubuntu"                          # This may be the same as your `Web` server
# role :db,  "ubuntu", :primary => true # This is where Rails migrations will run
# role :db,  "ubuntu"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true



# Roundsman fine-tuning

set :chef_version, '~> 11.6.0'

set :stream_roundsman_output, false # todo check why is this needed
set :debug_chef, true

set :ruby_version, "2.1.2"
set :care_about_ruby_version, true
set :group_writable, false
# set_default :ruby_install_dir, "/usr/local"


set :run_list, %w(
  recipe[apt]
  recipe[osrm]
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



namespace :mana do
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

  desc 'Install & update software'
  task :install do
    roundsman.chef.default

    # fix https://github.com/iain/roundsman/issues/26
    variables.keys.each { |k| reset! k }
  end

  desc 'Show install log'
  task :log do
    sudo "cat /tmp/roundsman/cache/chef-stacktrace.out"
  end

  desc 'Complete setup'
  task :setup do
    upgrade
    bootstrap
    install
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