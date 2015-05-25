
dashboard_name = node['dashing']['project_name']

# def stop_existing_dashboard(dashboard_name)

#     dashing_dashboard "/home/#{dashboard_name}" do
#     action :delete
#     port 8080
#     end
#     Chef::Log.info "dashing service stopped"  

#     script "delete dashboard" do
#     interpreter "bash"
#     user "root"
#     cwd "/home"
#     code <<-EOH
#     rm -rf "#{dashboard_name}"
#     EOH
#     end 
#     Chef::Log.info "#{dashboard_name} dashboard deleted"
# end

def install_dashing_dashboard_components

    apt_package "build-essential" do
      action :install
    end	

    #def nodejs
   script "install_nodejs" do
    interpreter "bash"
    user "root"
    cwd "/home"
    code <<-EOH
    sudo apt-get update
    sudo dpkg --configure -a
    sudo apt-get install nodejs -y
    EOH
   end  
   Chef::Log.info "Node js installed"
    #end

    #dashing gem requires minimum of ruby 1.9.3
    apt_package "ruby1.9.3" do
      action :install
    end 

    gem_package "bundler" do
      action :install
    end

    gem_package "dashing" do
      action :install
    end 

    Chef::Log.info "dashing prerequisites installed..."

end

#create new project and make the directory writable
 def writable_create_project(dashboard_name) 
	script "create_dashing_project" do
		interpreter "bash"
		user "root"
		cwd "/home"
		code <<-EOH
		dashing new "#{dashboard_name}"
		chmod 777 "#{dashboard_name}"
		cd "#{dashboard_name}"
		EOH
	end
	Chef::Log.info "#{dashboard_name} dashboard project created"

end  

def housekeeping(dashboard_name)

    script "removal_of_twitter_dashboard_job" do
      interpreter "bash"
      user "root"
      cwd "/home/#{dashboard_name}/jobs"
      code <<-EOH
      rm twitter.rb
      EOH
    end
   Chef::Log.info "housekeeping tasks completed"

 end

def new_dashboard_files(dashboard_name)  
      
	script "bundle_install" do
	interpreter "bash"
	user "root"
	cwd "/home/#{dashboard_name}"
	code <<-EOH
	bundle update
	bundle
	EOH
	end
	Chef::Log.info "gems installed..."
end

script "copy_dashboard_file" do
  interpreter "bash"
  user "root"
  cwd "/var/chef/cache/cookbooks/sample"
  code <<-EOH
  cp dashboard.sh /etc/init.d
  EOH
 
# notifies :start, "service[dashboard]"
  #not_if "test -f /etc/redis/lock"
end
Chef::Log.info "dashing service copied"

script "install_dashboard_as_a_service" do
  interpreter "bash"
  user "root"
  cwd "/etc/init.d"
  code <<-EOH
  mv dashboard.sh dashboard
  chmod 755 dashboard 
  sudo update-rc.d dashboard defaults
  EOH
 
#notifies :start, "execute[service dashboard start]"
  #not_if "test -f /etc/redis/lock"
end
Chef::Log.info "dashing service installed"

# service "dashboard" do 
#   action :start 
# end
execute 'service dashboard start' do
  cwd '/etc/init.d'
  not_if { ::File.exists?("/home/sample/dashing.pid")}
 end 
#=end 

#stop_existing_dashboard(dashboard_name)
install_dashing_dashboard_components 
writable_create_project(dashboard_name)
housekeeping(dashboard_name)
new_dashboard_files(dashboard_name)
