name 				'sample' # this is where Chef takes the cookbook name from!
maintainer 			'myself'
maintainer_email 	'aebirim@icloud.com' 
license 			'All rights reserved'
description 		'Cookbook for Dashing'
version 			'0.1.8'

#depends 'ruby_lwrp'
depends 'dashing'
depends 'chef-client'
depends 'chef_handler'