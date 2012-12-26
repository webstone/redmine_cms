
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

  # menu :top_menu, :cms, {:controller => 'pages', :action => 'index'}, :caption => :label_cms, :parent => :administration

  menu :admin_menu, :cms, {:controller => 'pages', :action => 'index'}, :caption => :label_cms

  # Redmine::MenuManager.map :top_menu do |menu|
  #   menu.push :projects, {:controller => 'admin', :action => 'projects'}, :caption => :label_project_plural, :parent => :administration
  #   menu.push :users, {:controller => 'users'}, :caption => :label_user_plural, :parent => :administration
  #   menu.push :groups, {:controller => 'groups'}, :caption => :label_group_plural, :parent => :administration
  #   menu.push :roles, {:controller => 'roles'}, :caption => :label_role_and_permissions, :parent => :administration
  #   menu.push :trackers, {:controller => 'trackers'}, :caption => :label_tracker_plural, :parent => :administration
  #   menu.push :issue_statuses, {:controller => 'issue_statuses'}, :caption => "Привет", :html => {:class => 'issue_statuses'}, :parent => :administration  
  # end

end

Redmine::MenuManager.items(:admin_menu).root.children.each do |node| 
  Redmine::MenuManager.map(:top_menu) do |menu| 
    menu.push(node.name.to_s + "_top", node.url, :parent => :administration) unless menu.exists?(node.name)
  end
end

CmsMenu.rebuild if CmsMenu.table_exists?

