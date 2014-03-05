User Example
------------

Adding name and avatar to user model


```
# Gemfile
gem "paperclip"
```

```
# bundle
bundle install
```


```
# migrations
rails g migration 'AddFirstNameToUsers' first_name:string
rails g migration 'AddLastNameToUsers' last_name:string
rails g paperclip user avatar
rake db:migrate

```

```
# app/models/user.rb
class User < ActiveRecord::Base
  ...
  has_attached_file :avatar, :styles => { :medium => "300x", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  ...
end
```


```
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  ...
  
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name << :last_name << :avatar
    devise_parameter_sanitizer.for(:account_update) << :first_name << :last_name << :avatar
  end
  
  ...
  
end
```

```
-# app/views/users/registrations/new.html.haml
%h2 Sign up
= simple_form_for(resource, :as => resource_name, :url => registration_path(resource_name)) do |f|
  = f.error_notification
  .form-inputs
    = f.input :first_name, :required => true, :autofocus => true
    = f.input :last_name, :required => true
    = f.input :avatar, as: :file
    = f.input :email, :required => true
    = f.input :password, :required => true
    = f.input :password_confirmation, :required => true
  .form-actions
    = f.button :submit, "Sign up"
= render "users/shared/links"
```


```
-# app/views/users/registrations/edit.html.haml
%h2
  Edit #{resource_name.to_s.humanize}
= simple_form_for(resource, :as => resource_name, :url => registration_path(resource_name), :html => { :method => :put }) do |f|
  = f.error_notification
  .form-inputs
    = f.input :first_name, :required => true, :autofocus => true
    = f.input :last_name, :required => true
    = f.input :avatar, input_html: {value: f.object.avatar.url(:medium)}
    = f.input :email, :required => true
    - if devise_mapping.confirmable? && resource.pending_reconfirmation?
      %p
        Currently waiting confirmation for: #{resource.unconfirmed_email}
    = f.input :password, :autocomplete => "off", :hint => "leave it blank if you don't want to change it", :required => false
    = f.input :password_confirmation, :required => false
    = f.input :current_password, :hint => "we need your current password to confirm your changes", :required => true
  .form-actions
    = f.button :submit, "Update"
%h3 Cancel my account
%p
  Unhappy? #{link_to "Cancel my account", registration_path(resource_name), :data => { :confirm => "Are you sure?" }, :method => :delete}
= link_to "Back", :back
```


Refresh thumbnails
```
rake paperclip:refresh:thumbnails CLASS=User
```


