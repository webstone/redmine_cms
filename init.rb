
Redmine::Plugin.register :redmine_cms do
  name 'Redmine CMS plugin'
  author 'RedmineCRM'
  description 'This is a CMS plugin for Redmine'
  version '0.0.1'
  url 'http://redminecrm.com'

  requires_redmine :version_or_higher => '2.1.2'   
  
  require 'redmine_cms'

  settings :default => {
    :use_localization => true,
    :base_layout => 'base'
  }, :partial => 'settings/cms'  

  project_module :project_tab do
    permission :view_project_tabs, { 
      :project_tabs => [:show]
    }    
    permission :manage_project_tabs, {
      :contacts_settings => :save
    }
  end

  Redmine::MenuManager.map :footer_menu do |menu|
    #empty
  end  

  Redmine::MenuManager.map :top_menu do |menu|
    #empty
  end  

  delete_menu_item(:top_menu, :home) 
  delete_menu_item(:top_menu, :"my_page")
  delete_menu_item(:top_menu, :"projects")
  delete_menu_item(:account_menu, :register)  

  delete_menu_item(:project_menu, :activity)
  delete_menu_item(:project_menu, :overview)

  5.downto(1) do |index|
    tab = "project_tab_#{index}".to_sym
    menu :project_menu, tab, {:controller => 'project_tabs', :action => 'show', :tab => index}, 
                             :first => :true,
                             :param => :project_id,
                             :caption => Proc.new{|p| ContactsSetting["project_tab_#{index}_caption".to_sym, p.id] || tab.to_s },
                             :if => Proc.new{|p| !ContactsSetting["project_tab_#{index}_caption".to_sym, p.id].blank? }

  end

  menu :top_menu, :cms, {:controller => 'pages', :action => 'index'}, :caption => :label_cms, :parent => :administration

  menu :admin_menu, :cms, {:controller => 'pages', :action => 'index'}, :caption => :label_cms

  Redmine::MenuManager.map :top_menu do |menu|
    menu.push :adm_projects, {:controller => 'admin', :action => 'projects'}, :caption => :label_project_plural, :parent => :administration
    menu.push :adm_users, {:controller => 'users'}, :caption => :label_user_plural, :parent => :administration
    menu.push :adm_groups, {:controller => 'groups'}, :caption => :label_group_plural, :parent => :administration
    menu.push :adm_roles, {:controller => 'roles'}, :caption => :label_role_and_permissions, :parent => :administration
    menu.push :adm_trackers, {:controller => 'trackers'}, :caption => :label_tracker_plural, :parent => :administration
    menu.push :adm_issue_statuses, {:controller => 'issue_statuses'}, :caption => :label_issue_status_plural, :html => {:class => 'issue_statuses'}, :parent => :administration
    menu.push :adm_workflows, {:controller => 'workflows', :action => 'edit'}, :caption => :label_workflow, :parent => :administration
    menu.push :adm_custom_fields, {:controller => 'custom_fields'},  :caption => :label_custom_field_plural, :html => {:class => 'custom_fields'}, :parent => :administration
    menu.push :adm_enumerations, {:controller => 'enumerations'}, :caption => :label_enumerations, :parent => :administration
    menu.push :adm_settings, {:controller => 'settings'}, :caption => :label_settings, :parent => :administration
    menu.push :adm_ldap_authentication, {:controller => 'auth_sources', :action => 'index'}, :caption => :label_ldap_authentication, :html => {:class => 'server_authentication'}, :parent => :administration
    menu.push :adm_plugins, {:controller => 'admin', :action => 'plugins'}, :caption => :label_plugins, :last => true, :parent => :administration
    menu.push :adm_info, {:controller => 'admin', :action => 'info'}, :caption => :label_information_plural, :last => true, :parent => :administration
  end


end

# Redmine::MenuManager.items(:admin_menu).root.children.each do |node| 
#   Redmine::MenuManager.map(:top_menu) do |menu| 
#     sub_node = node.clone
#     admin_menu = menu.find(:administration)
#     admin_menu.add sub_node unless menu.exists?(sub_node.name)
#     menu.push(node.name.to_s + "_top", node.url, :parent => :administration) unless menu.exists?(node.name)
#   end
# end

CmsMenu.rebuild if CmsMenu.table_exists?

