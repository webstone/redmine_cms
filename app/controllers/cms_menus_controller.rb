class CmsMenusController < ApplicationController
  unloadable

  before_filter :require_edit_permission
  before_filter :find_menu, :except => [:index, :new, :create]

  helper :cms

  def index
    redirect_to :controller => 'pages', :action => 'index', :tab => "cms_menus"
  end

  def edit

  end

  def new
    @cms_menu = CmsMenu.new
  end

  def update
    @cms_menu.assign_attributes(params[:cms_menu])
    if @cms_menu.save
      flash[:notice] = l(:notice_successful_update)
      @cms_menus = CmsMenu.all
      respond_to do |format|
        format.html {render :action =>"edit", :id => @cms_menus}
        format.js {render :action => "change"}
      end
    else
      render :action => 'edit'
    end
  end

  def create
    @cms_menu = CmsMenu.new(params[:cms_menu])
    if @cms_menu.save
      flash[:notice] = l(:notice_successful_create)
      render :action => 'edit', :id => @cms_menu
    else
      render :action => 'new'
    end
  end

  def destroy
    @cms_menu.destroy
    redirect_to :controller => 'pages', :action => 'index', :tab => "cms_menus"
  end

private
 def find_menu
  @cms_menu = CmsMenu.find(params[:id])
 end


  def require_edit_permission
    deny_access unless RedmineCms.allow_edit?
  end

end
