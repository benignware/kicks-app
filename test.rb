def copy_from_repo(filename, opts = {})
  repo = 'https://raw.github.com/rexblack/kicksapp/master/files/'
  #repo = 'https://raw.github.com/RailsApps/rails-composer/master/files/'
  source_filename = filename
  destination_filename = filename
  begin
    get repo + source_filename, destination_filename
  rescue OpenURI::HTTPError
    say_wizard "Unable to obtain #{source_filename} from the repo #{repo}"
  end
end



copy_from_repo "app/views/test.html.erb"

# gem 'ruby-bower', group: :assets
create_file '.bowerrc', <<-'CODE'
{"directory": "vendor/assets/components"}
CODE
# run "sudo npm install -g bower"
run "bower init"
run "bower install eonasdan-bootstrap-datetimepicker#latest --save"


