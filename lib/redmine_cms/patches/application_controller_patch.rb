module RedmineCMS
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          layout :use_layout_with_cms
          # after_filter :set_layout
          alias_method_chain :set_localization, :cms
          alias_method_chain :use_layout, :cms
          before_filter :menu_setup
          before_filter :cms_redirects
        end
      end


      module InstanceMethods
        def cms_redirects
          redirect_to RedmineCms.redirects[request.original_fullpath], :status => 301 if RedmineCms.redirects[request.original_fullpath]
        end

        def menu_setup
          # Check the settings cache for each request
          CmsMenu.check_cache
        end

        def set_layout
          # _layout = "cms"
          # self.class.layout "cms"
          self.class.layout(RedmineCms.base_layout) unless _layout == 'admin'
        end

        def use_layout_with_cms
          request.xhr? ? false : (RedmineCms.base_layout|| "base")
        end


        if Redmine::VERSION.to_s > '2.6'
          def set_localization_with_cms(user=User.current)
            if RedmineCms.settings[:use_localization]
              set_localization_without_cms
            else
              lang ||= Setting.default_language
              set_language_if_valid(lang)
            end
          end
        else
          def set_localization_with_cms
            if RedmineCms.settings[:use_localization]
              set_localization_without_cms
            else
              lang ||= Setting.default_language
              set_language_if_valid(lang)
            end
          end
        end

      end

    end
  end
end

unless ApplicationController.included_modules.include?(RedmineCMS::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineCMS::Patches::ApplicationControllerPatch)
end
