#### Scaffold resources
```
# scaffold Post
rails g scaffold Post title:string content:text
# scaffold Comment
rails g scaffold_assoc Post/Comment content:text
```

#### Authorization

```
# add userstamps to posts
rails g migration add_user_stamps_to_posts created_by_id:integer updated_by_id:integer
# add userstamps to comments
rails g migration add_user_stamps_to_comments created_by_id:integer updated_by_id:integer
```

```
# post.rb
class Post < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  belongs_to :updated_by, class_name: "User"
end
```

```
# comment.rb
class Comment < ActiveRecord::Base
  belongs_to :created_by, class_name: "User"
  belongs_to :updated_by, class_name: "User"
end
```

```
# ability.rb
class Ability
  include CanCan::Ability
  def initialize(user)
    can [:index, :show], [Post, Comment]
    if !user.nil?
      can :create, [Post, Comment]
      can :manage, [Post, Comment], created_by: user
      can :manage, Comment, post: {created_by: user}
    end
  end
end
```

### Customize views
```
# app/views/posts/show.html.haml
= link_to 'New Comment', new_post_comment_path(@post), class: 'btn btn-default'
```

#### Adding a RichText-Editor
Add 'bootstrap-wysihtml5-bower' dependency to bower.json
```
"bootstrap-wysihtml5-bower": ""
```
and run 'bower install'

```
// app/assets/javascripts/application.js
//= require bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5.all.min
```

```
// app/assets/stylesheets/application.scss
@import "bootstrap3-wysihtml5-bower/dist/bootstrap3-wysihtml5";
```

```
# app/inputs/html_input.rb
class HtmlInput < SimpleForm::Inputs::TextInput
  def input
    input_html_options[:class] << 'form-control'
    input_html_options[:rows]||= 10
    @builder.text_area(attribute_name, input_html_options)
  end
end
```

```
# app/assets/stylesheets/form_controls.css.scss
.form-control.html {
  max-width: 685px;
}
```





  