module RedmineCms
  module WikiMacros
    
    Redmine::WikiFormatting::Macros.register do
      desc "Include page"
      macro :include_page do |obj, args|
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        page = Page.find_by_name(args.first)
        raise 'Page not found' unless page
        render_page(page)
      end 

      desc "Link to page"
      macro :page do |obj, args|
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        page = Page.find_by_name(args.first)
        raise 'Page not found' unless page
        link_to page.title, page_path(page)
      end 

      desc "Link to page"
      macro :page_part do |obj, args, text|
        return "" unless obj.is_a?(Page)
        return "" if obj.blank?
        args, options = extract_macro_options(args, :parent)
        raise 'No or bad arguments.' if args.size != 1
        content_for(args.first.to_sym, textilizable(text, :attachments => obj.attachments ))
        ""
      end 

    end  

  end
end
