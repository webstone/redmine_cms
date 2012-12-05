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
        content_for(args.first.to_sym, textilizable(text, :object => obj, :attachments => obj.attachments ))
        ""
      end 

      desc "Feature with media"
      macro :feature do |obj, args, text|
        return "" unless obj.is_a?(Page)
        return "" if obj.blank?
        args, options = extract_macro_options(args, :parent, :class)
        feature_class = "feature #{options[:class] || ""}"
        # raise 'No or bad arguments.' if args.size != 1
        content = content_tag('div', textilizable(text, :object => obj, :attachments => obj.attachments), :class => "feature-content")
        content_tag('div', content, :class => feature_class)
      end 

      desc "Displays not clickable thumbnail of an attached image. Examples:\n\n<pre>{{plain_thumbnail(image.png)}}\n{{plain_thumbnail(image.png, size=300, title=Thumbnail, class=Teaser)}}</pre>"
      macro :plain_thumbnail do |obj, args|
        args, options = extract_macro_options(args, :size, :title, :class)
        filename = args.first
        raise 'Filename required' unless filename.present?
        size = options[:size]
        raise 'Invalid size parameter' unless size.nil? || size.match(/^\d+$/)
        size = size.to_i
        size = nil unless size > 0
        if obj && obj.respond_to?(:attachments) && attachment = Attachment.latest_attach(obj.attachments, filename)
          title = options[:title] || attachment.title
          img_class = options[:class] || ""
          img = image_tag(url_for(:controller => 'attachments', :action => 'thumbnail', :id => attachment, :size => size), :alt => attachment.filename, :class => img_class)
        else
          raise "Attachment #{filename} not found"
        end
      end

    end  

  end
end
