module Redmine
  module MenuManager
    module MenuHelper
      def render_menu_node(node, project=nil)
        if node.children.present? || !node.child_menus.nil?
          return render_menu_node_with_children(node, project)
        elsif allowed_node?(node, User.current, project)
          caption, url, selected = extract_node_details(node, project)
          return content_tag('li',
                               render_single_menu_node(node, caption, url, selected))
        end
      end

      def render_single_menu_node(item, caption, url, selected)
        link_to(caption.html_safe, url, item.html_options(:selected => selected))
      end

    end
  end
end