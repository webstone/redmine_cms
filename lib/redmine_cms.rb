require 'liquid/tags'
require 'liquid/filters'
require 'liquid/paginate'

Dir[File.dirname(__FILE__) + '/liquid/drops/*.rb'].each { |f| require f }

require 'redmine_cms/helpers/cms_helper'

require 'redmine_cms/patches/projects_helper_patch'
require 'redmine_cms/patches/menu_manager_patch'
require 'redmine_cms/patches/acts_as_attachable_patch'
require 'redmine_cms/patches/attachments_controller_patch'
require 'redmine_cms/patches/application_controller_patch'
require 'redmine_cms/patches/projects_controller_patch'
require 'redmine_cms/patches/welcome_controller_patch'
require 'redmine_cms/patches/attachment_patch'

require 'redmine_cms/hooks/views_layouts_hook'
require 'redmine_cms/wiki_macros/cms_wiki_macros'

require 'acts_as_versionable'

module RedmineCms

  STATUS_ACTIVE = 1
  STATUS_LOCKED = 0


  class << self
    def settings() Setting[:plugin_redmine_cms].is_a?(Hash) ? Setting[:plugin_redmine_cms] : {} end

    def cache_expires_in
      expires_in = self.settings[:cache_expires_in].to_i
      expires_in > 0 ? expires_in : 15
    end

    def layout
      self.settings[:base_layout]
    end

    def allow_edit?(user=User.current)
      user_ids = [user.id] + user.groups.map(&:id)
      return true if user.admin?
      return true if user_ids.include?(self.settings[:edit_permissions].to_i) && user.logged?
      false
    end

    def redirects
      settings[:redirects].is_a?(Hash) ? settings[:redirects] : settings[:redirects] = {}
    end

    def save_settings
      # cms_settings = self.settings
      # cms_settings = {} unless cms_settings.is_a?(Hash)
      # cms_settings.merge!(index => value)
      Setting.plugin_redmine_cms = self.settings
    end

    def set_project_settings(name, project_id, v)
      settings[:project] = {project_id => {}} unless settings[:project]
      settings[:project][project_id] = {name => ''} unless settings[:project][project_id]
      settings[:project][project_id][name] = v if settings[:project][project_id]
      Setting[:plugin_redmine_cms] = settings
    end

    def get_project_settings(name, project_id)
      settings[:project][project_id][name] if settings[:project] && settings[:project][project_id]
    end
  end


end