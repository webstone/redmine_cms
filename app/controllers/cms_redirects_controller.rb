class CmsRedirectsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_redirect, :except => [:index, :new, :create]

  def index
    redirect_to :controller => 'settings', :action => 'plugin', :id => "redmine_cms", :tab => "cms_redirects"
  end

  def new
    @cms_redirect = CmsRedirect.new
  end

  def edit
  end

  def update
    new_cms_redirect = CmsRedirect.new(params[:cms_redirect])
    if new_cms_redirect.valid?
      new_cms_redirect.save
      @cms_redirect.destroy
      flash[:notice] = l(:notice_successful_update)
      redirect_to cms_redirects_path
    else
      source_path = @cms_redirect.source_path
      @cms_redirect = new_cms_redirect
      @cms_redirect.source_path = source_path
      render :action => 'edit'
    end
  end

  def create
    @cms_redirect = CmsRedirect.new(params[:cms_redirect])
    if @cms_redirect.valid?
      @cms_redirect.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to cms_redirects_path
    else
      render :action => 'new'
    end
  end

  def destroy
    @cms_redirect.destroy
    redirect_to cms_redirects_path
  end

  private

  def find_redirect
    parametrized_redirects = RedmineCms.redirects.map{|k, v| [k, v]}.inject({}){|memo, (key, value)| memo[key.parameterize] = {:s => key, :d => value}; memo}
    redirect = parametrized_redirects[params[:id].gsub(/^_$/, "")]
    render_404 unless redirect
    @cms_redirect = CmsRedirect.new(:source_path => redirect.try(:[], :s), :destination_path => redirect.try(:[], :d))
  end
end
