def source_paths
  Array(super) + 
    [File.join(File.expand_path(File.dirname(__FILE__)), '.')]
end

# include gems
gem "haml"
gem "haml-rails"
gem 'html2haml'
gem "devise"
gem "simple_form"
gem 'compass-rails'
gem 'bootstrap-sass', '~> 3.0.3.0'

# rename application.css to application.sass
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.sass"

# install bootstrap
run "gem install bootstrap-sass"
create_file "app/assets/stylesheets/_variables.sass"
prepend_to_file 'app/assets/stylesheets/application.sass', "@import '_variables'\n@import 'bootstrap'\n"
append_to_file 'app/assets/stylesheets/application.sass', <<-CODE
body
  padding-top: $navbar-height
  
body > .container
  padding-top: 10px
  padding-bottom: 50px
    
.form-control
  max-width: 300px
CODE

append_to_file 'app/assets/javascripts/application.js', "//= require bootstrap\n"

# simple_form bootstrap3 initializer
copy_file "config/initializers/simple_form_bootstrap3.rb"

#generate "simple_form:install --bootstrap"

# copy layout templates
run "rm app/views/layouts/application.html.erb"
template "app/views/layouts/_header.html.haml"
template "app/views/layouts/_footer.html.haml"
template "app/views/layouts/application.html.haml"
template "app/views/layouts/full.html.haml"

# install devise
generate "devise:install"
generate "model user --skip"
generate "devise user --skip"
generate "devise:views"
# convert devise views to haml
run "for file in app/views/devise/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done"

# generate home page

route "root 'index#index'"  

#generate "controller index index --skip-template-engine"
create_file "app/controllers/index_controller.rb", <<-CODE
class IndexController < ApplicationController
  def index
    render view: 'index', layout: 'full'
  end
end
CODE
template "app/views/index/index.html.haml"

# migrate
rake "db:migrate"
