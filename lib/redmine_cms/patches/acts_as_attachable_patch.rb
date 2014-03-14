module Redmine
  module Acts
    module Attachable
      def self.included(base)
        base.extend ClassMethods
      end

      module InstanceMethods

        def attachments_visible?(user=User.current)
          !self.respond_to?(:project) ||
          ((respond_to?(:visible?) ? visible?(user) : true) &&
                      user.allowed_to?(self.class.attachable_options[:view_permission], self.project))
        end

        def attachments_deletable?(user=User.current)
          !self.respond_to?(:project) ||
          ((respond_to?(:visible?) ? visible?(user) : true) &&
                      user.allowed_to?(self.class.attachable_options[:delete_permission], self.project))
        end

        module ClassMethods
        end
      end
    end
  end
end
