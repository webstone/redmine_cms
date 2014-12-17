module RedmineCms
  module CmsHelper
    def favicon_cms
      if current_theme && current_theme.images.include?('favicon.ico')
        "<link rel='shortcut icon' href='#{current_theme.image_path('/favicon.ico')}' />".html_safe
      else
        favicon
      end
    end

    def render_account_menu
      s = "<ul>"
      if User.current.logged?
        s << "<li>#{avatar(User.current, :size => "16").to_s.html_safe + link_to_user(User.current, :format => :username) }"
          links = []
          menu_items_for(:account_menu) do |node|
            links << render_menu_node(node)
          end
          s << (links.empty? ? "" : content_tag('ul', links.join("\n").html_safe, :class => "menu-children"))

        s << "</li>"
      else
        s << "<li>#{link_to l(:label_login), signin_path}</li>"
      end
      s << "</ul>"
      s.html_safe
    end

    def render_page(page)
      s = "".html_safe
      s << cached_render_part(page)
      page.pages_parts.order(:position).active.each do |pages_part|
        case pages_part.part.part_type
        when "content"
          s << cached_render_part(pages_part.part)
        else
          content_for(pages_part.part.part_type.to_sym, render_part(pages_part.part))
        end
      end
      s
    end

    def cached_render_part(part)
      if part.respond_to?(:is_cached) && part.is_cached?
        Rails.cache.fetch(part, :expires_in => RedmineCms.cache_expires_in.minutes) {render_part(part)}
      else
        render_part(part)
      end
    end

    def render_liquid(content, part=nil)
      assigns = {}
      assigns['users'] = UsersDrop.new(User.sorted)
      assigns['projects'] = ProjectsDrop.new(Project.visible.order(:name))
      assigns['newss'] = NewssDrop.new(News.visible.order("#{News.table_name}.created_on"))
      assigns['current_page'] = params[:page] || 1
      assigns['page'] = PageDrop.new(@page) if @page
      assigns['pages'] = PagesDrop.new(Page.scoped({}))
      assigns['params'] = self.params if self.respond_to?(:params)
      assigns['request'] = RequestDrop.new(request)
      assigns['now'] = Time.now.utc
      assigns['today'] = Date.today
      assigns['layout'] = LayoutDrop.new

      registers = {}
      registers[:part] = part if part
      registers["projects"] = ProjectsDrop.new(Project.order(:name))
      begin
        ::Liquid::Template.parse(content).render(::Liquid::Context.new({}, assigns, registers)).html_safe
      rescue => e
        e.message
      end
    end

    def render_part(part)

      s = case part.content_type
          when "textile"
            textilizable(part, :content, :attachments => part.attachments)
          when "html"
            render_liquid(part.content, part)
          when "java_script"
            "<script type=\"text/javascript\">#{part.content.html_safe}</script>".html_safe
          when "css"
            "<style type=\"text/css\">#{part.content.html_safe}</style>".html_safe
          else
            part.content
          end

      # (part.is_a?(Part) && ["textile", "html"].include?(part.content_type))? content_tag(:span, s, :id => part.name, :class => "part") : s
    end
  end
end

ActionView::Base.send :include, RedmineCms::CmsHelper
