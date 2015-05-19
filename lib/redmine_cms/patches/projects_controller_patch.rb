module RedmineCms
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :show, :cms
          helper :pages
        end
      end

      module InstanceMethods

        def show_with_cms
          if params[:jump]
            # try to redirect to the requested menu item
            redirect_to_project_menu_item(@project, params[:jump]) && return
          end

          unless !User.current.allowed_to?(:view_project_tabs, @project) || (page_path = ContactsSetting["landing_page", @project.id]).blank?
            if page_path.to_i > 0 && page_path.to_i < 11
              page_path = {:controller => 'project_tabs', :action => 'show', :tab => page_path.to_i.to_s, :project_id => @project}
            end
            redirect_to page_path, :status => 301
          else
            show_without_cms
          end
        end

      end

    end
  end
end


unless ProjectsController.included_modules.include?(RedmineCms::Patches::ProjectsControllerPatch)
  ProjectsController.send(:include, RedmineCms::Patches::ProjectsControllerPatch)
end