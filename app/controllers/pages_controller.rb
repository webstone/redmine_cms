class PagesController < ApplicationController
  unloadable
  layout 'admin', :except => :show
  before_filter :require_admin, :except => :show
  before_filter :find_page, :except => [:index, :new, :create]
  # before_filter :find_optional_project, :only => :show

  def index
    @pages = Page.all
  end

  def show
    render_404 unless @page.status_id != 1
    respond_to do |format|
      format.html {render :action => 'show', :layout => 'base'} 
    end    
  end

  def edit
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
      redirect_to :action =>"index"
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
      redirect_to :action =>"index"
    else
      render :action => 'new'
    end
  end 

  def destroy
    @page.destroy
    redirect_to :action => 'index'
  end    

private
  def find_page
    @page = Page.find_by_name(params[:id])
    render_404 unless @page
  end

end
