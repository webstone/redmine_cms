class PartsController < ApplicationController
  unloadable
  before_filter :require_edit_permission
  before_filter :find_part, :except => [:index, :new, :create]

  helper :attachments
  helper :cms

  def index
    redirect_to :controller => 'pages', :action => 'index', :tab => "parts"
  end

  def show
    set_content_from_version if params[:version]
    redirect_to edit_part_path(@part) if %w(css java_script).include?(@part.content_type)
  end

  def edit
    set_content_from_version if params[:version]
  end

  def expire_cache
    Rails.cache.delete(@part)
    redirect_to :back
  end

  def new
    @part = Part.new(:content_type => 'textile')
    @part.copy_from(params[:copy_from]) if params[:copy_from]
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
      respond_to do |format|
        format.html do
          # if params[:unlock]
          #   redirect_to :controller => 'pages', :action => 'index', :tab => "parts"
          # else
            redirect_to :action =>"edit", :id => @part
          # end
        end
        format.js {render :nothing => true}
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
      redirect_to :action =>"edit", :id => @part
    else
      render :action => 'new'
    end
  end

  def destroy
    if params[:version]
      version = @part.versions.where(:version => params[:version]).first
      if version.current_version?
        flash[:warning] = l(:label_cms_version_cannot_destroy_current)
      else
        version.destroy
      end
      redirect_to history_part_path(@page)
    else
      @part.destroy
      redirect_to :controller => 'pages', :action => 'index', :tab => "parts"
    end
  end

  def history
    @versions = @part.versions
    @version_count = @versions.count
  end

  def diff
    @diff = @part.diff(params[:version], params[:version_from])
    render_404 unless @diff
  end

  def annotate
    @annotate = @part.annotate(params[:version])
    render_404 unless @annotate
  end

private
  def find_part
    @part = Part.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def require_edit_permission
    deny_access unless RedmineCms.allow_edit?
  end

  def set_content_from_version
    return if !@page
    @version = @page.versions.where(:version => params[:version]).first
    @page.content = @version.content if @version
  end

end
