require_dependency 'redmine/syntax_highlighting'
require_dependency 'uv'

#
# Monkeypatches for the Ultraviolet (Uv) module:
# * Allow Uv.syntax_for_file to handle blobs of content (without existing files)
# * Add THEMES and DEFAULT_THEME
#
module Uv
  
  DEFAULT_THEME = "pastels_on_dark"
  THEMES = %w[
    active4d
    all_hallows_eve
    amy
    blackboard
    brilliance_black
    brilliance_dull
    cobalt
    dawn
    eiffel
    espresso_libre
    idle
    iplastic
    lazy
    mac_classic
    magicwb_amiga
    pastels_on_dark
    slush_poppies
    spacecadet
    sunburst
    twilight
    zenburnesque
  ]

  def Uv.syntax_for_file file_name, content=nil
    init_syntaxes unless @syntaxes
    
    f = content ? StringIO.new(content) : open(file_name)
    first_line = f.find { |line| line.strip.size > 0 }  # first non-empty line
    f.close

    result = []
    
    @syntaxes.each do |key, value|
      assigned = false
      
      if value.fileTypes
        value.fileTypes.each do |t|
          if t == File.basename( file_name ) || t == File.extname( file_name )[1..-1]
            result << [key, value] 
            assigned = true
            break
          end
        end
      end
      
      unless assigned
        if value.firstLineMatch && value.firstLineMatch =~ first_line
          result << [key, value] 
        end
      end
    end
    
    result
  end
  
end

#
# UV Syntax highlighting for Redmine
#
module UltravioletSyntaxPatch
    require 'uv'
    class << self
      #def syntax_highlight_with_uv_syntax_highlight(name, content)
      def highlight_by_filename(content,name)#text, filename)
        require 'uv'
        ## See: http://ultraviolet.rubyforge.org/svn/lib/uv.rb 
        ## See: http://ultraviolet.rubyforge.org/themes.xhtml
      
        ## User selection of UV Theme
        user_theme = User.current.custom_value_for(CustomField.first(:conditions => {:name => 'Ultraviolet Theme'}))
        @uv_theme_name = user_theme || ::Uv::DEFAULT_THEME

        syntaxes = ::Uv.syntax_for_file(name, content)

        if syntaxes.empty?
          syntax_name = "plain_text"
        else
          syntax_name = syntaxes.first.first
        end
        puts "hello"
        # Usage: Uv.parse(text, output="xhtml", syntax_name=nil, line_numbers=false, render_style="classic", headers=false)
        return Uv.parse(content, "xhtml", syntax_name, true, @uv_theme_name)
      end
    
      def highlight_by_language(content,syntax_name)
        require 'uv'
        ## See: http://ultraviolet.rubyforge.org/svn/lib/uv.rb 
        ## See: http://ultraviolet.rubyforge.org/themes.xhtml
      
        ## User selection of UV Theme
        user_theme = User.current.custom_value_for(CustomField.first(:conditions => {:name => 'Ultraviolet Theme'}))
        @uv_theme_name = user_theme || ::Uv::DEFAULT_THEME

        # Usage: Uv.parse(text, output="xhtml", syntax_name=nil, line_numbers=false, render_style="classic", headers=false)
        return ::Uv.parse(content, "xhtml", syntax_name, true, @uv_theme_name).sub('<pre class=','<span class=').gsub('</pre>','</span>')
      end
    end
end

Redmine::SyntaxHighlighting.highlighter = 'UltravioletSyntaxPatch'
