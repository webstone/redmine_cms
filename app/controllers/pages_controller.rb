class PagesController < ApplicationController
  unloadable

  layout 'admin', :except => [:show, :edit]
  before_filter :require_edit_permission, :except => :show
  before_filter :find_page, :except => [:index, :new, :create]
  before_filter :authorize_page, :only => :show

  helper :attachments
  helper :cms_menus
  helper :parts
  helper :cms

  def index
    @pages = Page.all
    @parts = Part.all
    @cms_menus = CmsMenu.all
  end

  def show
    respond_to do |format|
      format.html {render :action => 'show', :layout => use_layout}
    end
  end

  def edit
    @pages_parts = @page.pages_parts.order_by_type
    respond_to do |format|
      format.html {render :action => 'edit', :layout => use_layout}
    end
  end

  def new
    @page = Page.new
    @page.copy_from(params[:copy_from]) if params[:copy_from]
    respond_to do |format|
      format.html {render :action => 'new', :layout => use_layout}
    end
  end

  def update
    @page.assign_attributes(params[:page])
    @page.save_attachments(params[:attachments])
    if @page.save
      render_attachment_warning_if_needed(@page)
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html {redirect_to :action =>"show", :id => @page}
        format.js {render :nothing => true}
      end
    else
      render :action => 'edit'
    end
  end

  def create
    @page = Page.new(params[:page])
    @page.save_attachments(params[:attachments])
    if @page.save
      render_attachment_warning_if_needed(@page)
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action =>"show", :id => @page
    else
      render :action => 'new'
    end
  end

  def destroy
    @page.destroy
    redirect_to :controller => 'settings', :action => 'plugin', :id => "redmine_cms", :tab => "pages"
  end

  def expire_cache
    Rails.cache.delete(@page)
    @page.parts.each do |part|
      Rails.cache.delete(part)
    end
    redirect_to :back
  end

private
  def authorize_page
    @project = @page.page_project || (params[:project_id] && Project.find(params[:project_id]))
    deny_access unless @page.visible?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_page
    @page = Page.includes([:attachments, :parts, :pages_parts]).includes(:parts => :attachments).find_by_name(params[:id])
    render_404 unless @page
  end

  def require_edit_permission
    deny_access unless RedmineCms.allow_edit?
  end

end
