def copy_from_repo(filename, opts = {})
  repo = 'https://raw.github.com/rexblack/kicks-app/master/files/'
  #repo = 'https://raw.github.com/RailsApps/rails-composer/master/files/'
  source_filename = filename
  destination_filename = filename
  get repo + source_filename, destination_filename
end



copy_from_repo "app/views/test.html.erb"

# gem 'ruby-bower', group: :assets
create_file '.bowerrc', <<-'CODE'
{"directory": "vendor/assets/components"}
CODE
# run "sudo npm install -g bower"
run "bower init"
run "bower install eonasdan-bootstrap-datetimepicker#latest --save"


