class CmsVariablesController < ApplicationController

  before_filter :find_variable, :only => [:edit, :update, :destroy]
  before_filter :require_admin
  def new
    @variable = CmsVariable.new
  end

  def create
    @variable = CmsVariable.new
    @variable.safe_attributes = params[:cms_variable]
    if @variable.save
      flash[:notice] = l(:notice_successful_create)
      respond_to do |format|
        format.html { redirect_to cms_settings_path(:tab => "variables") }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js
      end
    end
  end

  def update
    @variable.safe_attributes = params[:cms_variable]
    if @variable.save
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_to cms_settings_path(:tab => "variables") }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.js
      end
    end
  end

  def edit
  end

  def destroy
    @variable.destroy
    respond_to do |format|
      format.html { redirect_to cms_settings_path(:tab => "variables") }
    end
  end

private
  
  def find_variable
    @variable = CmsVariable.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end