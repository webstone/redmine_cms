module PagesHelper
  def render_page(page)
    case page.content_type
    when "textile"
      textilizable(page, :content, :attachments => page.attachments)
    when "html"
      page.content.html_safe
    else
      page.content
    end  

  end

   def page_breadcrumb(page)
    return unless page.parent
    pages = page.ancestors.reverse
    pages << page
    links = pages.map {|ancestor| link_to(h(ancestor.title), page_path(ancestor))}
    breadcrumb links
  end

  def pages_options_for_select(pages)
    options = []
    Page.page_tree(pages) do |page, level|
      label = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      label << page.name
      options << [label, page.id]
    end
    options
  end 
end
