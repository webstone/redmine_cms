class ProjectTabsController < ApplicationController
  unloadable

  before_filter :find_project_by_project_id, :authorize

  helper :pages

  def show
    menu_items[:project_tabs][:actions][:show] = "project_tab_#{params[:tab]}".to_sym
    @page = Page.find_by_name(ContactsSetting["project_tab_#{params[:tab]}_page", @project.id])
    render_404 unless @page   
    render_403 if @page.project && @page.project != @project 
  end

private

  def find_page
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
