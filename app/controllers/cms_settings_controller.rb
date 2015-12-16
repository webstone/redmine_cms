class CmsSettingsController < ApplicationController
  unloadable
  menu_item :cms_settings

  layout 'admin'
  before_filter :require_admin
  before_filter :find_settings

  helper :cms

  def index
    @pages = Page.all
    @parts = Part.all
    @cms_redirects = CmsRedirect.all
    @cms_menus = CmsMenu.all
  end

  def update
    params[:settings].each do |key, value|
      @settings[key] = value
    end
    Setting.plugin_redmine_cms = @settings
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'index', :tab => params[:tab]
  end

  def edit
  end

  def save
    find_project_by_project_id
    if params[:cms_settings] && params[:cms_settings].is_a?(Hash) then
      settings = params[:cms_settings]
      settings.map do |k, v|
        # ContactsSetting[k, @project.id] = v
        RedmineCms.set_project_settings(k, @project.id, v)
      end
    end
    redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => params[:tab]
  end


private

  def find_settings
    @settings = Setting.plugin_redmine_cms
    @settings = {} unless @settings.is_a?(Hash)
  end

end
