class PagesController < ApplicationController
  unloadable
  layout 'admin', :except => [:show, :edit]
  before_filter :require_admin, :except => :show
  before_filter :find_page, :except => [:index, :new, :create]
  before_filter :check_status, :only => :show
  # before_filter :find_optional_project, :only => :show

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
    @page_keywords = @page.keywords if @page.keywords
    @page_description = @page.description
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
  end

  def update
    @page.assign_attributes(params[:page])
    @page.save_attachments(params[:attachments])
    if @page.save
      render_attachment_warning_if_needed(@page)
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action =>"show", :id => @page
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
    redirect_to :action => 'index'
  end   

  def expire_cache
    expire_fragment(@page)
    @page.parts.each do |part|
      expire_fragment(part)
    end
    redirect_to :back
  end 

private
  def find_page
    @page = Page.find_by_name(params[:id])
    render_404 unless @page
  end

  def check_status
    render_404 unless @page.active?
  end

end
