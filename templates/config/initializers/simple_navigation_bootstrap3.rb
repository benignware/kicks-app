module SimpleNavigation
  module Renderer
    
    # Renders an ItemContainer as a <ul> element and its containing items as <li> elements.
    # It adds the 'selected' class to li element AND the link inside the li element that is currently active.
    #
    # If the sub navigation should be included (based on the level and expand_all options), it renders another <ul> containing the sub navigation inside the active <li> element.
    #
    # By default, the renderer sets the item's key as dom_id for the rendered <li> element unless the config option <tt>autogenerate_item_ids</tt> is set to false.
    # The id can also be explicitely specified by setting the id in the html-options of the 'item' method in the config/navigation.rb file.
    class Bootstrap3NavBarRenderer < SimpleNavigation::Renderer::Base
      
      def render(item_container)
        list_content = item_container.items.inject([]) do |list, item|
          li_options = item.html_options.reject {|k, v| k == :link}
          if item_container === SimpleNavigation.primary_navigation && item.selected?
            li_options[:class] = options[:class].nil? ? "active" : options[:class].split("\s+").uniq.join("active")
          end
          li_content = tag_for(item)
          if !item.sub_navigation.nil?
            li_content << render_sub_navigation_for(item)
          end
          list << content_tag(:li, li_content, li_options)
        end.join
        if skip_if_empty? && item_container.empty?
          ''
        else
          content_tag((options[:ordered] ? :ol : :ul), list_content, {:id => item_container.dom_id, :class => [item_container.dom_class, item_container === SimpleNavigation.primary_navigation ? 'nav navbar-nav' : 'dropdown-menu'].join(" ")})
        end
      end
      
      def tag_for(item)
        options = options_for(item)
        classes = !options[:class].nil? ? options[:class].split("\s+") : []
        name = item.name
        if !item.sub_navigation.nil?
          classes.push("dropdown-toggle")
          options[:data]||= {}
          options[:data][:toggle] = 'dropdown'
          name << " " << content_tag("b", "", class: 'caret')
        end
        options[:class] = classes.uniq.join(" ")
        link_to(name, item.url.nil? ? '#' : item.url, options)
      end
      
    end
  end
end
SimpleNavigation.register_renderer :bootstrap3_navbar => SimpleNavigation::Renderer::Bootstrap3NavBarRenderer