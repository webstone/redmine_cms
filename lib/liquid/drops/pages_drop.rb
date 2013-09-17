class PagesDrop < Liquid::Drop

  def initialize(pages)
    @pages = pages
  end

  def before_method(name) 
    page = @pages.where(:name => name).first || Page.new
    PageDrop.new page
  end

  def all
    @all ||= @pages.map do |page|
      PageDrop.new page
    end
  end

  def visible
    @visible ||= @pages.visible.map do |page|
      PageDrop.new page
    end
  end  

  def each(&block) 
    all.each(&block)
  end

end


class PageDrop < Liquid::Drop

  delegate :name, :title, :description, :content, :content_type, :to => :@page

  def initialize(page)
    @page = page
  end

  def url
    helpers.page_url(@page, :only_path => true)
  end

  def children
    @children ||= @page.children.map{|p| PageDrop.new(p)}
  end

  def parent
    @parent ||= PageDrop.new(@page.parent) if @page.parent
  end

  private

  def helpers
    Rails.application.routes.url_helpers
  end    

end