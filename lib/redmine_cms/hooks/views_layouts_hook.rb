module RedmineCms
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context={})
        return stylesheet_link_tag(:cms, :plugin => 'redmine_cms')
      end
    end
  end
end