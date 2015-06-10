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
    @settings.merge!(params[:settings])
    Setting.plugin_redmine_cms = @settings
    flash[:notice] = l(:notice_successful_update)
    redirect_to :action => 'index', :tab => params[:tab]
  end

  def edit
  end


private

  def find_settings
    @settings = Setting.plugin_redmine_cms
    @settings = {} unless @settings.is_a?(Hash)
  end

end
