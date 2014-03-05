TeamsExample
------------

```
# Gemfile
gem "mail"
gem "devise_invitable"
# TODO: gem attendable
#gem "attendable"
```

```
rails g devise_invitable:install
rails g devise_invitable User
rails g attendable:install
rake db:migrate
```

```
rails g devise_invitable:views users
```


```
# config/environments/development.rb
  ...
  # mailer settings
  config.mailer_sender = "xxx@xxx.com"  
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  
  config.action_mailer.logger = nil
  
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
  
  config.action_mailer.smtp_settings = {
    :address => "smtp.xxx.com",
    :port => "25",
    :domain => "xxx.com",
    :user_name => "xxx@xxx.com",
    :password => "xxx",
    :authentication => :plain 
  }
```

```
# config/routes.rb
resources :teams do
  member do
    post 'invite'
    get 'rsvp'
  end
end
```


```
rails g scaffold Team name:string
rails g navigation_item Team
rails g paperclip team image
rake db:migrate

```


```
# app/models/team.rb
class Team < ActiveRecord::Base
  include Attendable
  is_attendable by: :users, as: :team_members
  has_attached_file :image, :styles => { :medium => "640x", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
  
```

# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    can [:index, :show], Team
    if !user.nil?
      can :create, Team
      can :manage, Team do |team|  
        team.is_attending?(user)  
      end  
    end
  end
end

```
# app/controllers/teams_controller.rb
class TeamsController < ApplicationController

  before_action :set_team, only: [:show, :edit, :update, :destroy, :invite, :rsvp]
  
  before_filter :authenticate_user!, only: [:new, :edit, :create, :destroy]
  load_and_authorize_resource
  
  def create
    @team = Team.new(team_params)
    @team.team_members.build({user: current_user, status: :attending})
    ...
  end
    
  ...
  
  def invite
  
    params[:invitations][:emails].split(",").each do |email|
      user = User.invite!(:email => email)
      @team.team_members.create(user: user, status: 'pending')
    end
    
    respond_to do |format|
      
      format.html { redirect_to @team, notice: 'Invitations have been successfully sent.' }
      format.json { head :no_content }
      
    end
  end
  
  
  def rsvp
    team_member = @team.team_members.where(["user_id = ?", current_user.id])[0]
    if team_member
      team_member.status = params[:status]
      if team_member.save
        redirect_to @team, notice: 'status was successfully updated.'
      else
        #TODO: ajax error message
        redirect_to @team, notice: 'status could not be saved.'
      end
    else
      # user was not invited
      #TODO: ajax error message
      redirect_to @team, notice: 'You are not invited to the team.'
    end
    
  end
  
  ...
  # add image to trusted params
  def team_params
    params.require(:team).permit(:name, :image)
  end
  
end
  
```


```
-# app/views/teams/_form.html.haml
= simple_form_for(@team) do |f|
  = f.error_notification

  .form-inputs
    = f.input :name
    = f.input :image, input_html: {value: (f.object.image.url(:medium) if f.object.image.present?) }
  
  .form-actions
    = f.button :submit
```





```
-# app/views/teams/show.html.haml


.row
  - @team.attendees.each do |user|
    .profile.col-md-2.col-sm-3.col-xs-6
      .thumbnail
        = image_tag(user.avatar.url(:medium))
        %h5= user.first_name + " " + user.last_name
        
        
.actions
  .btn-group
    - if current_user
      - if @team.is_member?(current_user)
        = link_to(content_tag(:i, '', class: 'glyphicon glyphicon-ok') << " Attend", rsvp_team_path(@team, {status: @team.is_attending?(current_user) ? :declined : :attending}), class: 'btn btn-default btn-attend btn-attend-team' + ( @team.attendees.include?(current_user) ? " attending" : "" ))
      - if @team.is_attending?(current_user)
        %button.btn.btn-primary{data: {toggle:"modal", target:"#send-team_invitations"}}='Send invitations'

.modal.fade#send-team_invitations{tabindex:-1, role:"dialog", aria:{labelledby:"send-team_invitations-label", hidden:"true"}}
  .modal-dialog
    = simple_form_for :invitations, url: invite_team_path(@team), :html=> { class: 'modal-content' } do |f|
      .modal-header
        %button.close{type:"button", data: {dismiss:"modal"}, aria:{hidden:"true"}}='&times'.html_safe
        %h4.modal-title#send-team_invitations-label='Send invitations'
      .modal-body
        = f.input :emails
      .modal-footer
        %button.btn.btn-default{type:"button", data:{dismiss:"modal"}}='Close'
        = f.submit 'Send', class: 'btn btn-primary'
```


```
// assets/stylesheets/teams.css.scss
.btn-attend {
  i {
    opacity: 0.3
  }
  &.attending i {
    opacity: 1
  }
}
```

```
// assets/stylesheets/application.scss
@import "teams";
```


