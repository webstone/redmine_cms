module RedmineCMS
  module Patches
    module ApplicationControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          after_filter :set_layout
          alias_method_chain :set_localization, :cms
          alias_method_chain :use_layout, :cms
          # skip_before_filter :set_localization, :only => [:method_name]
        end
      end


      module InstanceMethods
        # include ContactsHelper

        def set_layout
          # _layout = "cms"
          self.class.layout "cms"
          # self.class.layout(RedmineCms.settings[:base_layout] || "base") unless _layout == 'admin'
        end

        def use_layout_with_cms
          request.xhr? ? false : (RedmineCms.settings[:base_layout] || "base") unless _layout == 'admin'
        end

        def set_localization_with_cms
          if RedmineCms.settings[:use_localization]
            set_localization_without_cms
          end
        end
        
      end
      
    end
  end
end

unless ApplicationController.included_modules.include?(RedmineCMS::Patches::ApplicationControllerPatch)
  ApplicationController.send(:include, RedmineCMS::Patches::ApplicationControllerPatch)
end
