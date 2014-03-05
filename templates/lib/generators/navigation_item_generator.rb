class NavigationItemGenerator < Rails::Generators::Base
  desc "This generator creates an navigation item"
  argument :resource, :type => :string
  # def create_initializer_file
    # create_file "config/initializers/initializer.rb", "# Add initialization content here"
  # end
  
  def create_navigation_item
    # Rails.application.routes.routes.each do |route|
      # if resource
      # puts route.name.to_s << " --- " << route.defaults.controller.to_s
    # end
    if !File.open('config/navigation.rb').read().match(/#{resource.tableize}/)
    
      inject_into_file 'config/navigation.rb', :before => /end[\s\n\t]*end[\s\n\t]*\z/ do
        <<-CODE
      primary.item :#{resource.tableize}_menu, '#{resource.pluralize}', '#', {} do |sub_nav|
        sub_nav.item :#{resource.tableize}, 'All #{resource.tableize}', #{resource.tableize}_path, {}
        sub_nav.item :new_#{resource.underscore}, 'New #{resource.tableize.singularize}', new_#{resource.tableize.singularize}_path, {}
      end
        CODE
      end
    else
      puts 'a navigation item with this resource id does already exist'
    end
    
  end
  
end