
```
# app/models/event.rb
class Event < ActiveRecord::Base
  include Attendable
  is_attendable by: :users, as: :event_members
  belongs_to :team
end
```


```
# config/routes.rb
resources :events do
  member do
    get 'rsvp'
  end
end
```
