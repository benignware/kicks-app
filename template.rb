add_source File.dirname(__FILE__)

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
initializer 'simple_form_bootstrap3.rb', <<-'CODE'
inputs = %w[
  CollectionSelectInput
  DateTimeInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]
 
inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::\\#{input_type}".constantize
  new_class = Class.new(superclass) do
    def input_html_classes
      super.push('form-control')
    end
  end
  Object.const_set(input_type, new_class)
end
SimpleForm.setup do |config|
  
  config.boolean_style = :nested
  config.button_class = 'btn btn-default'
  
  config.wrappers :bootstrap3, tag: 'div', class: 'form-group', error_class: 'has-error',
      defaults: { input_html: { class: 'default_class' } } do |b|
    
    b.use :html5
    b.use :min_max
    b.use :maxlength
    b.use :placeholder
    
    b.optional :pattern
    b.optional :readonly
    
    b.use :label_input
    b.use :hint,  wrap_with: { tag: 'span', class: 'help-block' }
    b.use :error, wrap_with: { tag: 'span', class: 'help-block has-error' }
  end
 
  config.default_wrapper = :bootstrap3
end

CODE

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
