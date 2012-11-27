module RedmineCMS
  module Patches
    module AttachmentPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :project, :cms
          # skip_before_filter :find_project, :only => [:method_name]
        end
      end


      module InstanceMethods
        # include ContactsHelper

        def project_with_cms
          if container.respond_to?(:project)
            container.try(:project) 
          else
            false
          end  
        end
        
      end
      
    end
  end
end

unless Attachment.included_modules.include?(RedmineCMS::Patches::AttachmentPatch)
  Attachment.send(:include, RedmineCMS::Patches::AttachmentPatch)
end
