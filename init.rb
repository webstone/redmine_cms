

Redmine::Plugin.register :redmine_cms do
  name 'Redmine CMS plugin'
  author 'RedmineCRM'
  description 'This is a CMS plugin for Redmine'
  version '0.0.1'
  url 'http://redminecrm.com'

  require 'redmine_cms'

  project_module :project_tab do
    permission :view_project_tabs, { 
      :project_tabs => [:show]
    }    
    permission :manage_project_tabs, {
      :contacts_settings => :save
    }
  end
  

  # delete_menu_item(:top_menu, :home)
  # delete_menu_item(:top_menu, :"my_page")
  # delete_menu_item(:project_menu, :activity)

  (1..5).each do |index|
    tab = "project_tab_#{index}".to_sym
    menu :project_menu, tab, {:controller => 'project_tabs', :action => 'show', :tab => index}, 
                             :after => :overview,
                             :param => :project_id,
                             :caption => Proc.new{|p| ContactsSetting["project_tab_#{index}_caption".to_sym, p.id] || tab.to_s },
                             :if => Proc.new{|p| !ContactsSetting["project_tab_#{index}_caption".to_sym, p.id].blank? }

  end

  menu :admin_menu, :cms, {:controller => 'pages', :action => 'index'}, :caption => :label_cms

end


CmsMenu.rebuild if CmsMenu.table_exists?