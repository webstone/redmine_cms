class PagesPartsController < ApplicationController
  before_filter :find_page_and_part

  helper :cms

  def add
    @page.parts << @part
    @page.save
    respond_to do |format|
      format.html { redirect_to :back }  
      format.js {render :action => "change"}
    end
  end

  def update
    @pages_part = PagesPart.find_by_part_id_and_page_id(@part, @page)
    @pages_part.update_attributes(params[:pages_part])
    @pages_part.save
    respond_to do |format|
      format.html { redirect_to :back }  
      format.js {render :action => "change"}
    end    
  end

  def delete  
    @page.parts.delete(@part) if request.delete?
    respond_to do |format|
      format.html { redirect_to :back }
      format.js {render :action => "change"}
    end   
  end

private
  def find_page_and_part
    @page = Page.find_by_name(params[:page_id])
    @part = Part.find(params[:part_id])
    @parts = @page.parts 
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
