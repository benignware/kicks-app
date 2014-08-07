```
# Gemfile
gem 'acts_as_attendable', github: 'rexblack/acts_as_attendable'
```

```
bundle install
rails g attendable:install
rails g scaffold Event title:string date:datetime
rails g navigation_item Event
rake db:migrate
```

```
# app/models/event.rb
class Event < ActiveRecord::Base
  acts_as_attendable by: :users, as: :event_members
end
```

```
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    can [:index, :show], Event
    if !user.nil?
      can [:create, :rsvp], Event
    end
  end
end

```

```
# app/controllers/events_controller.rb
class EventsController < ApplicationController

  before_action :set_event, only: [:show, :edit, :update, :destroy, :rsvp]
  
  before_filter :authenticate_user!, only: [:new, :edit, :create, :destroy, :rsvp]
  load_and_authorize_resource
  
  ...
  
  def create
    @event = Event.new(event_params)
    @event.event_members.build({user: current_user, status: :attending})
    ...
  end
  
  ...
  
  def rsvp
    event_member = @event.event_members.where(["user_id = ?", current_user.id])[0]
    if event_member
      event_member.status = params[:status]
    else
      # no member
      event_member = @event.event_members.build({user: current_user, status: :attending})
    end
    if event_member.save
      redirect_to @event, notice: 'Status was successfully updated.'
    else
      redirect_to @event, notice: 'Status could not be saved.'
    end
    
  end
  
  ...
  
  
```

```
# app/views/events/show.html.haml
    
...
    %tr.row
      %td.col-sm-1='Attendees'
      %td
        - @event.attendees.each do |user|
          %p
            = "User #" + user.id.to_s

.actions
  .btn-group
    - if current_user
      = link_to(content_tag(:i, '', class: 'glyphicon glyphicon-ok') << " Attend", rsvp_event_path(@event, {status: @event.is_attending?(current_user) ? :declined : :attending}), class: 'btn btn-default btn-attend btn-attend-event' + ( @event.attendees.include?(current_user) ? " attending" : "" ))

```

```
// assets/stylesheets/events.css.scss
.btn-attend-event {
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



```
# config/routes.rb
resources :events do
  member do
    get 'rsvp'
  end
end
```
