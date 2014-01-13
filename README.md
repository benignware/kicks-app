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

Scaffold the article model
```
rails g scaffold Article title:string content:text
```

Add a user column to the article model
```
rails g migration AddUserIdToArticles user_id:integer
```

Apply the migrations to the database
```
rake db:migrate
```

Add belongs_to association to article model
```
belongs_to :user
```

Add has_many association to article model
```
has_many :user
```

Edit app/controllers/articles_controller.rb to add authorization filters and populate user column with current_user on create action
```
class ArticlesController < ApplicationController
  
  before_filter :authenticate_user!, only: [:new, :edit, :create, :destroy]
  load_and_authorize_resource

  ...

  def create
    @article = Article.new(article_params)
    @article.user = current_user
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
      can :read, Article
    else
      can :manage, Article, user_id: user.id
    end
  
  end

end
```


Edit app/views/_header.html.haml to include posts in navigation
```
...

%ul.nav.navbar-nav
  %li
    %a{:href => articles_path} Articles
  %li
    %a{:href => new_article_path} New Article
    
...
```

You're done. Start server to test your application
```
rails s
```






