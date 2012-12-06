class PartsController < ApplicationController
  unloadable
  layout 'admin'
  before_filter :require_admin
  before_filter :find_part, :except => [:index, :new, :create]

  helper :attachments
  helper :cms

  def index
    redirect_to :controller => 'pages', :action =>"index", :tab => 'parts'
  end

  def show
    respond_to do |format|
      format.html {render :action => 'show', :layout => 'base'} 
    end    
  end

  def edit
    respond_to do |format|
      format.html {render :action => 'edit', :layout => 'base'} 
    end    
  end

  def new
    @part = Part.new(:content_type => 'textile')
  end

  def refresh
    expire_fragment(@part)
  end

  def update
    @part.assign_attributes(params[:part])
    @part.save_attachments(params[:attachments])
    if @part.save
      render_attachment_warning_if_needed(@part)
      flash[:notice] = l(:notice_successful_update)
      if params[:unlock] 
        redirect_to :controller => 'pages', :action =>"index", :tab => 'parts'
      else
        redirect_to :action =>"show", :id => @part
      end
    else
      render :action => 'edit'
    end
  end

  def create
    @part = Part.new(params[:part])
    @part.save_attachments(params[:attachments])
    if @part.save
      render_attachment_warning_if_needed(@part)
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action =>"show", :id => @part
    else
      render :action => 'new'
    end
  end 

  def destroy
    @part.destroy
    redirect_to :controller => 'pages', :action => 'index', :tab => 'parts'
  end    

private
  def find_part
    @part = Part.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
