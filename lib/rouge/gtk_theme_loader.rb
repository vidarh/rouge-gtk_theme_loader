#
# # GtkThemeLoader
#
# Tries to load different GtkSourceView themes
# as Rouge themes
#

require 'nokogiri'

module Rouge
  class GtkThemeLoader
  
    include Rouge::Token::Tokens

    THEME_PATHS=[
      "/usr/share/gtksourceview-2.0/styles/*.xml",
      "/usr/share/gtksourceview-3.0/styles/*.xml",
      "/usr/share/gtksourceview-4/styles/*.xml",
      "~/.config/rouge/themes/*.xml"
      ]

      # Mapping of GTK source view mappings.
      GTKMAPPING = {
        "def:string"       => Literal::String,
        "def:constant"     => Literal,
        "def:number"       => Literal::Number,
        "def:variable"     => Name::Variable,
        "def:keyword"      => Keyword,
        "def:statement"    => Keyword,
        "def:comment"      => Comment,
        "def:type"         => [Name::Constant, Name::Namespace],
        "def:identifier"   => Name::Builtin,
        "def:emphasis"     => Generic::Emph,
        "def:preprocessor" => Name::Builtin,
      }

      def self.load!
        THEME_PATHS.each do |path|
          Dir[File.expand_path(path).to_s].each do |theme|
            GtkThemeLoader.load(theme)
          end
        end
      end
      
      class GtkTheme < Rouge::CSSTheme
        def self.other_styles
          @other_styles ||= {}
        end

        def other_styles
          self.class.other_styles
        end
      end

      # Attempt to get a color that's not
      # entirely unreadable when a theme is stupid
      # Will fail horribly for all kinds of values.
      def self.contrast(col)
        r,g,b = col[1..2].to_i(16), col[3..4].to_i(16), col[5..6].to_i(16)
        rn,gn,bn = 255-r, 255-g,255-b
        "#%02x%02x%02x" % [rn,gn,bn]
      end
      
      def self.load(theme)
        xml =  Nokogiri.XML(File.read(theme))
        theme = Class.new(ReTheme)
        name = xml.xpath("/style-scheme").attr("id").value
        theme.name(name)
        
        xml.xpath("//color").each do |c|
          theme.palette(c.attr("name").to_sym => c.attr("value").to_sym)
        end
        
        # Rouge barfs if we don't have a default style, so let's make sure
        @text = xml.xpath("//style[@name='text']").first
        if @text
          
          theme.style(Text,
          :fg => @text.attr("foreground").to_sym,
          :bg => @text.attr("background").to_sym
        )
      else
        bgp = xml.xpath("//style[@name='background-pattern']")
        if bgp
          bg = bgp.attr("background").value
        end
        bg ||= "#000000"
        if bg[0] == ?#
          fg = contrast(bg)
        end
        theme.style(Text, :fg => fg, :bg => bg, :underline => true)
      end
      
      xml.xpath("//style").each do |node|
        name = node.attr("name")
        
        use = node.attr("use-style")
        if use && GTKMAPPING[use]
          #  name = use
        end
        rougetype = GTKMAPPING[name]
        fg = node.attr("foreground")
        fg = @text.attr("foreground") if @text && !fg
        fg = fg.to_sym if fg && fg[0] != '#'
        bg = node.attr("background")
        fg = @text.attr("background") if @text && !fg
        bg = bg.to_sym if bg && bg[0] != '#'
        opts = {}
        opts[:bg] = bg if bg
        if fg
          opts[:fg] = fg
        end
        
        opts[:italic]    = true if node.attr("italic").to_s == "true"
        opts[:bold]      = true if node.attr("bold").to_s == "true"
        opts[:underline] = true if node.attr("underline")&.to_s == "true"
        
        if name.index(":") != nil
          Array(rougetype).each do |rt|
            theme.style(rt, opts)
          end
        end
        theme.other_styles[name] = opts
      end
    end
  end
end

Rouge::GtkThemeLoader.load!
