require 'liquid/tags'
require 'liquid/filters'
require 'liquid/paginate'

Dir[File.dirname(__FILE__) + '/liquid/drops/*.rb'].each { |f| require f }

require 'redmine_cms/patches/projects_helper_patch'
require 'redmine_cms/patches/application_helper_patch'
require 'redmine_cms/patches/menu_manager_patch'
require 'redmine_cms/patches/acts_as_attachable_patch'
require 'redmine_cms/patches/attachments_controller_patch'
require 'redmine_cms/patches/application_controller_patch'
require 'redmine_cms/patches/projects_controller_patch'
require 'redmine_cms/patches/welcome_controller_patch'
require 'redmine_cms/patches/settings_controller_patch'
require 'redmine_cms/patches/attachment_patch'

require 'redmine_cms/hooks/views_layouts_hook'
require 'redmine_cms/wiki_macros/cms_wiki_macros'

module RedmineCms

  STATUS_ACTIVE = 1
  STATUS_LOCKED = 0

  def self.settings() Setting[:plugin_redmine_cms] ? Setting[:plugin_redmine_cms] : {} end

  def self.set_project_settings(name, project_id, v)
    settings[:project] = {project_id => {}} unless settings[:project]
    settings[:project][project_id] = {name => ''} unless settings[:project][project_id]
    settings[:project][project_id][name] = v if settings[:project][project_id]
    Setting[:plugin_redmine_cms] = settings
  end

  def self.get_project_settings(name, project_id)
    settings[:project][project_id][name] if settings[:project] && settings[:project][project_id]
  end

end