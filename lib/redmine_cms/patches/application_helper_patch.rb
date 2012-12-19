module RedmineCMS
  module Patches
    module ApplicationHelperPatch
      
      def self.included(base)
        base.send(:include, InstanceMethods)
      end


      module InstanceMethods
        def render_page(page)
          s = "".html_safe
          s << cached_render_part(page)
          page.pages_parts.order(:position).active.each do |pages_part|
            case pages_part.part.part_type
            when "header"
              content_for(:header, render_part(pages_part.part))
            when "sidebar"
              content_for(:sidebar, render_part(pages_part.part))
            when "footer"
              content_for(:footer, render_part(pages_part.part))
            when "content"
              s << cached_render_part(pages_part.part)
            end  
          end
          s
        end

        def cached_render_part(part)
          if part.respond_to?(:is_cached) && part.is_cached?
            Rails.cache.fetch(part, :expires_in => 15.minutes) {render_part(part)}
          else
            render_part(part)
          end
        end

        def render_part(part)
          assigns = { 'part' => part }

          registers = {
            :controller     => self,
            :part           => part
          }

          s = case part.content_type
              when "textile"
                textilizable(part, :content, :attachments => part.attachments)
              when "html"
                Liquid::Template.parse(part.content).render(Liquid::Context.new({}, assigns, registers)).html_safe 
              when "java_script"
                "<script type=\"text/javascript\">#{part.content.html_safe}</script>".html_safe 
              when "css"
                "<style type=\"text/css\">#{part.content.html_safe}</style>".html_safe 
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
