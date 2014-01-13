kicks-app
=========

Rails kickstarter template containing full setup for devise, bootstrap, simple form and other gems

* devise
* haml-rails
* compass-rails
* bootstrap-sass 3.0.3
* simple_form

Usage
-----

Create a new app from the command line
```
rails new Project -m 'https://raw.github.com/rexblack/kicks-app/master/template.rb'
```

Move to the new application directory and start server
```
rails s
```

There you go...


Example blog application
------------------------

Scaffold the post model
```
rails g scaffold Post title:string content:text
```

Add a user column to the post model
```
rails g migration AddUserIdToPosts user_id:integer
```

Apply the migrations to the database
```
rake db:migrate
```

Edit app/controllers/posts_controller.rb to add authorization filters and populate user column with current_user on create action
```
class PostsController < ApplicationController
  
  before_filter :authenticate_user!, only: [:new, :edit, :create, :destroy]
  load_and_authorize_resource

  ...

  def create
    @post = Team.new(team_params)
    @post.user = current_user
    ...
  end

  ...

end

```


Edit app/models/Ability.rb to authorize users to manage their own posts
```
class Ability
  include CanCan::Ability

  def initialize(user)
    
    user ||= User.new # guest user (not logged in)
    if user.nil?
      can :read, Post
    else
      can :manage, Post, user_id: user.id
    end
  
  end

end
```


Edit app/views/_header.html.haml to include posts in navigation
```
...

%ul.nav.navbar-nav
  %li
    %a{:href => posts_path} Posts
  %li
    %a{:href => new_post_path} New Post
    
...
```

You're done. Start server to test your application
```
rails s
```






