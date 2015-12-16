module RedmineCms
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      include RedmineCms::CmsHelper

      def view_layouts_base_html_head(context={})
        s = ''
        s << stylesheet_link_tag(:cms, :plugin => 'redmine_cms')
        layout_html_head_parts.each do |part|
          s << render_part(part)
        end
        s
      end

      def view_layouts_base_sidebar(context = { })
        s = ''
        layout_base_sidebar_parts.each do |part|
          s << render_part(part)
        end
        s
      end

      def view_layouts_cms_body_top(context = { })
        s = ''
        layout_body_top_parts.each do |part|
          s << render_part(part)
        end
        s
      end

      def view_layouts_base_body_bottom(context = { })
        s = ''
        layout_body_bottom_parts.each do |part|
          s << render_part(part)
        end
        s
      end

    end
  end
end