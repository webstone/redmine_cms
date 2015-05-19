module RedmineCms
  module Patches
    module WelcomeControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          caches_action :sitemap, :expires_in => 1.week

          helper :pages
        end
      end

      module InstanceMethods

        def sitemap
          @projects = Project.all_public.active
          @pages = Page.where(:project_id => nil).active.all
          respond_to do |format|
            format.xml
          end
        end

      end

    end
  end
end

unless WelcomeController.included_modules.include?(RedmineCms::Patches::WelcomeControllerPatch)
  WelcomeController.send(:include, RedmineCms::Patches::WelcomeControllerPatch)
end