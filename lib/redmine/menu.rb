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
