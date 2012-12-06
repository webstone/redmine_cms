module RedmineCMS
  module Patches
    module ApplicationHelperPatch
      
      def self.included(base)
        base.send(:include, InstanceMethods)
      end


      module InstanceMethods
        def render_page(page)

          page.header_parts.each do |part|
            content_for(:header, render_part(part))
          end

          page.sidebar_parts.each do |part|
            content_for(:sidebar, render_part(part))
          end

          page.footer_parts.each do |part|
            content_for(:footer, render_part(part))
          end          

          s = "".html_safe
          page.content_parts.each do |part|
            s << render_part(part)
          end
          s
        end

        def render_part(part)
          case part.content_type
          when "textile"
            textilizable(part, :content, :attachments => part.attachments)
          when "html"
            part.content.html_safe
          else
            part.content
          end  
        end        

      end
      
    end
  end
end

unless ApplicationHelper.included_modules.include?(RedmineCMS::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedmineCMS::Patches::ApplicationHelperPatch)
end
