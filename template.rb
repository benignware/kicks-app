# TODO: database.yml.sample
# TODO: optionally create github-repo - http://developer.github.com/v3/repos/#create

# include gems
gem "haml"
gem "haml-rails"
gem 'html2haml'
gem "devise"
gem "simple_form"
gem 'compass-rails'
gem 'bootstrap-sass', '~> 3.0.3.0'
gem 'cancan'

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

# simple form
generate "simple_form:install"

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
  superclass = "SimpleForm::Inputs::#{input_type}".constantize
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

# remove application layout
run "rm app/views/layouts/application.html.erb"

# layout templates

# install devise
generate "devise:install"
generate "model user --skip"
generate "devise user --skip"
generate "devise:views"
# convert devise views to haml
run "for file in app/views/devise/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done"


# install cancan
generate "cancan:ability"


# application-controller
insert_into_file "app/controllers/application_controller.rb", after: "class ApplicationController < ActionController::Base" do 
  
  # alert permission denied on root page
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  # FIXME: patch to get cancan to work with rails 4
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end
  
end

# views

# header
create_file "app/views/layouts/_header.html.haml", <<-'CODE'
.navbar.navbar-inverse.navbar-fixed-top
  .container
    .navbar-header
      %button.navbar-toggle{:type => "button", :data => {:toggle => "collapse", :target => ".navbar-collapse"} }
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
      = link_to Rails.application.class.parent_name, root_path, :class => "navbar-brand"
    .collapse.navbar-collapse
      %ul.nav.navbar-nav
        %li
          %a{:href => "#"} Link #1
        %li
          %a{:href => "#"} Link #2
        %li
          %a{:href => "#"} Link #3
       
      - if !current_user   
        = simple_form_for(User.new, as: :user, url: session_path(:user), html: {class: 'navbar-form navbar-right'}) do |f|
          = f.input :email, required: false, autofocus: true, placeholder: "Email", label: false, input_html: {size: 0}
          = f.input :password, required: false, placeholder: "Password", label: false, input_html: {size: 0}
          = f.button :submit, "Sign in", class: 'btn-success'
      - else  
        %ul.nav.navbar-nav.navbar-right
          %li.dropdown
            %a.dropdown-toggle{data: {toggle: 'dropdown'}}
              Account
              %b.caret
            %ul.dropdown-menu
              %li
                %a{:href => edit_user_registration_path} Profile
              %li
                = link_to "Sign out", destroy_user_session_path, :method => :delete            
CODE

# footer partial
create_file "app/views/layouts/_footer.html.haml", <<-'CODE'
%footer
  .container
    %p
      &copy; Company 2013
CODE

# application layout
create_file "app/views/layouts/application.html.haml", <<-'CODE'
!!!
%html
  %head
    %meta{:charset => "utf-8"}
    %title Starter Template for Bootstrap
    %meta{:content => "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no", :name => "viewport"}
    %meta{:content => "", :name => "description"}
    %meta{:content => "", :name => "author"}

    / Le HTML5 shim, for IE6-8 support of HTML5 elements
    /[if lt IE 9]
      = javascript_include_tag "https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js", "https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"

    = stylesheet_link_tag    "application", :media => "all", "data-turbolinks-track" => true
    = javascript_include_tag "application", "data-turbolinks-track" => true
    = csrf_meta_tags
  %body
    
    = render partial: 'layouts/header'
           
    .container
      - flash.each do |name, msg|
        = content_tag :div, :class => "alert alert-#{name == :error ? "danger" : "success" } alert-dismissable" do
          %button.close{:type => "button", :data => {:dismiss => "alert"}, :aria => {:hidden => "true"} } &times;
          = msg
      = yield
      
    
    = render partial: 'layouts/footer'
CODE


create_file "app/views/layouts/full.html.haml", <<-'CODE'
!!!
%html
  %head
    %meta{:charset => "utf-8"}
    %title Starter Template for Bootstrap
    %meta{:content => "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no", :name => "viewport"}
    %meta{:content => "", :name => "description"}
    %meta{:content => "", :name => "author"}

    / Le HTML5 shim, for IE6-8 support of HTML5 elements
    /[if lt IE 9]
      = javascript_include_tag "https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js", "https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"

    = stylesheet_link_tag    "application", :media => "all", "data-turbolinks-track" => true
    = javascript_include_tag "application", "data-turbolinks-track" => true
    = csrf_meta_tags
  %body
    
    = yield
CODE



# generate home page

route "root 'index#index'"  


# index controller
create_file "app/controllers/index_controller.rb", <<-'CODE'
class IndexController < ApplicationController
  def index
    render view: 'index', layout: 'full'
  end
end
CODE


create_file "app/views/index/index.html.haml", <<-'CODE'
= render partial: 'layouts/header'

.jumbotron
  .container
    %h1= 'Hello world!'
    %p This is a skeleton application with integrated authentication using devise and bootstrap views
    - if !current_user
      %p
        = link_to t('Sign up') + " &raquo;".html_safe , new_user_registration_path, class: 'btn btn-primary btn-lg'
    
    - flash.each do |name, msg|
      = content_tag :div, :class => "alert alert-#{name == :error ? "danger" : "success" } alert-dismissable" do
        %button.close{:type => "button", :data => {:dismiss => "alert"}, :aria => {:hidden => "true"} } &times;
        = msg

.container
  .row
    .col-md-4
      %h2='Heading'
      %p
        Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.
      %a.btn.btn-default{href: '#'}
        View details &raquo;
    .col-md-4
      %h2='Heading'
      %p
        Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.
      %a.btn.btn-default{href: '#'}
        View details &raquo;
    .col-md-4
      %h2='Heading'
      %p
        Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.
      %a.btn.btn-default{href: '#'}
        View details &raquo;
    %hr

= render partial: 'layouts/footer'
CODE

git :init
git add: "."
git commit: "-a -m 'Initial commit'"

# migrate
rake "db:migrate"