module RedmineCms
  module Liquid
    module Filters
      include ApplicationHelper
      include Rails.application.routes.url_helpers

      def textilize(input)
        RedCloth3.new(input).to_html
      end

      def attachment_url(input)
        return '' if input.nil?
        part, filename = get_part(input)
        attachment = part.attachments.where(:filename => filename).first
        attachment ? "/attachments/download/#{attachment.id}/#{attachment.filename}" : "attachment #{filename} not found"
      end

      # example:
      #   {{ 'image.png' | thumbnail_url: 'size:100' }}
      def thumbnail_url(input, *args)
        return '' if input.nil?
        options = args_to_options(args)
        size   = options[:size] || '100'
        ss.match(/(^\S+):/)
        part, filename = get_part(input)
        attachment = part.attachments.where(:filename => filename).first
        attachment ? "/attachments/thumbnail/#{attachment.id}/#{size}" : "attachment #{filename} not found"
      end  

      # example:
      #   {{ 'image.png' | thumbnail_tag: 'size:100', 'title:A title', 'width:100px', 'height:200px'  }}
      def thumbnail_tag(input, *args)
        return '' if input.nil?
        image_options = inline_options(args_to_options(args))
        options = args_to_options(args)
        size   = options[:size] || '100'
        part, filename = get_part(input)
        attachment = part.attachments.where(:filename => filename).first
        attachment ? "<img src=\"/attachments/thumbnail/#{attachment.id}/#{size}\" #{image_options}/>"  : "attachment #{filename} not found"
      end   

      # example:
      #   {{ 'image.png' | fancybox_tag: 'size:100', 'title:A title', 'width:100px', 'height:200px'  }}
      def fancybox_tag(input, *args)
        return '' if input.nil?
        image_options = inline_options(args_to_options(args))
        options = args_to_options(args)
        size   = options[:size] || '100'
        # part, filename = get_part(input)
        # attachment = part.attachments.where(:filename => filename).first
        "<a rel=\"fancybox_group\" href=\"#{attachment_url(input)}\" title=\"#{options[:title]}\">#{thumbnail_tag(input, *args)}</a><p>#{options[:title]}</p>"
      end    

      # example:
      #   {{ 'image.png' | asset_image_tag: 'title:A title', 'width:100px', 'height:200px'  }}
      def asset_image_tag(input, *args)
        return '' if input.nil?
        image_options = inline_options(args_to_options(args))
        options = args_to_options(args)
        "<img src=\"/plugin_assets/redmine_cms/images/#{input}\" #{image_options}/>" 
      end    

      # example:
      #   {% paginate users.all by 5 %}{{ paginate | default_pagination }}{% endpaginate %}
      def default_pagination(paginate)
        current_page = paginate['current_page']
        pages = paginate['pages']
        result = ''
        if paginate['previous']
          result += %Q( <span class="prev"><a href="#{paginate['previous']['url']}">« #{paginate['previous']['title']}</a></span>)
        end
        paginate['parts'].each do |part|
          page =  part['title']
          if page == (current_page + 3) and page != pages
            result += %Q( <span class="deco">...</span>)
          elsif page > (current_page + 3) and page != pages #省略
          elsif page == (current_page - 3) and page != 1
            result += %Q( <span class="deco">...</span>)
          elsif page < (current_page - 3) and page != 1 #省略
          else
            if part['is_link']
              result += %Q( <span class="page"><a href="#{part['url']}">#{page}</a></span>)
            else
              result += %Q( <span class="page current">#{page}</span>)
            end
          end
        end
        if paginate['next']
          result += %Q( <span class="next"><a href="#{paginate['next']['url']}">#{paginate['next']['title']} »</a></span>)
        end
        result
      end        

    protected  

      # Convert an array of properties ('key:value') into a hash
      # Ex: ['width:50', 'height:100'] => { :width => '50', :height => '100' }
      def args_to_options(*args)
        options = {}
        args.flatten.each do |a|
          if (a =~ /^(.*):(.*)$/)
            options[$1.to_sym] = $2
          end
        end
        options
      end

      # Write options (Hash) into a string according to the following pattern:
      # <key1>="<value1>", <key2>="<value2", ...etc
      def inline_options(options = {})
        return '' if options.empty?
        (options.stringify_keys.sort.to_a.collect { |a, b| "#{a}=\"#{b}\"" }).join(' ') << ' '
      end

      def get_part(input)
        if m = input.match(/(^\S+):(.+)$/)
          part = Part.find_by_name(m[1])
          filename = m[2]
        end
        part ||= @context.registers[:part]
        filename ||= input
        [part, filename]
      end

    end
  end

  ::Liquid::Template.register_filter(RedmineCms::Liquid::Filters)  
end