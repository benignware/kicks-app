puts 'kicks-app v0.1'
puts '--------------'

def source_paths
  Array(super) + 
    [File.join(File.expand_path(File.dirname(__FILE__)))]
end


# create templates
directory 'templates', '.'
create_file '.bowerrc', '{"directory": "vendor/assets/components"}'
gsub_file 'bower.json', /"name"\:\s*"app-name"/, "\"name\": \"#{app_name}\"" # replace app-name

run "rm app/views/layouts/application.html.erb" # remove application.html.erb

#application controller patch
insert_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base" do 
<<-'CODE'

  # alert permission denied on root page
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end
  
  # FIXME: patch to get cancan to work with rails 4
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
CODE
end

insert_into_file "app/assets/javascripts/application.js", before: "//= require_tree ." do 
<<-'CODE'
//= require modernizr/modernizr
//= require bootstrap/dist/js/bootstrap.min
//= require moment/min/moment.min
//= require eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min
//= require jquery-filepicker/src/js/jquery.filepicker
CODE
end

gsub_file 'app/assets/stylesheets/application.css', /\s*\*=\s*require_tree\s*\./, "" # delete require_tree 
append_to_file 'app/assets/stylesheets/application.css', <<-CODE
@import "_variables";
@import "bootstrap";
@import "eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min";
@import "form_controls";
@import "layouts";
CODE
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss" # rename application.css to application.scss

# gem dependencies
gem "haml"
gem "haml-rails"
gem 'html2haml'
gem 'compass-rails'
gem "simple_form"
gem 'simple-navigation'
gem "devise"
gem 'cancan'
gem 'bootstrap-sass'

gem 'scaffold_assoc', github: 'rexblack/scaffold_assoc'

run  'bundle install'

# install and configure gems
generate "simple_form:install" # simple_form
generate "devise:install" # simple_form


# models
# generate "model User"
# generate "migration add_first_name_to_users first_name:string -skip"
# generate "devise User -skip"

generate "model User --skip"
#generate "migration AddFirstNameToUsers first_name:string --skip"
generate "devise User --skip"
gsub_file 'config/initializers/devise.rb', /#\s*config\.scoped_views\s*=\s*false/, "config.scoped_views = true" # delete require_tree 
  
  
generate "cancan:ability"

# migrate
rake "db:migrate"

# routes
route "root 'index#index'"

# helpers
insert_into_file "app/helpers/application_helper.rb", after: "module ApplicationHelper\n" do 
<<-'CODE'
  def title(page_title, options={})
    content_for(:title, page_title.to_s)
    return content_tag(:h1, page_title, options)
  end
CODE
end

# views
generate "devise:views users"
run "for file in app/views/users/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done" # convert devise views to haml

# client-side dependencies

# init bower
run "bower install"

