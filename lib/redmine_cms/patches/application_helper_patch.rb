module RedmineCMS
  module Patches
    module ApplicationHelperPatch
      
      def self.included(base)
        base.send(:include, InstanceMethods)
      end


      module InstanceMethods
        def render_page(page)
          case page.content_type
          when "textile"
            textilizable(page, :content, :attachments => page.attachments)
          when "html"
            page.content.html_safe
          else
            page.content
          end  
        end
      end
      
    end
  end
end

unless ApplicationHelper.included_modules.include?(RedmineCMS::Patches::ApplicationHelperPatch)
  ApplicationHelper.send(:include, RedmineCMS::Patches::ApplicationHelperPatch)
end
