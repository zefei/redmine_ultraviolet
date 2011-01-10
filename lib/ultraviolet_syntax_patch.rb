require_dependency 'redmine/syntax_highlighting'
require_dependency 'uv'

#require_dependency 'application_helper'

#
# Monkeypatches for the Ultraviolet (Uv) module:
# * Allow Uv.syntax_for_file to handle blobs of content (without existing files)
# * Add THEMES and DEFAULT_THEME
#
module Uv
  
  DEFAULT_THEME = "mac_classic"
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

  def self.included(base) # :nodoc:
      base.send(:include, self)
    end
    
    class << self
      
      #def syntax_highlight_with_uv_syntax_highlight(name, content)
      def highlight_by_filename(content,name)#text, filename)
        ## See: http://ultraviolet.rubyforge.org/svn/lib/uv.rb 
        ## See: http://ultraviolet.rubyforge.org/themes.xhtml
      
      
        syntaxes = Uv.syntax_for_file(name, content)

        if syntaxes.empty?
          syntax_name = "plain_text"
        else
          syntax_name = syntaxes.first.first
        end
        #puts "hello"
        # Usage: Uv.parse(text, output="xhtml", syntax_name=nil, line_numbers=false, render_style="classic", headers=false)
        Uv.parse(content, "xhtml", syntax_name, true, get_uv_theme_name)
      end
    
      def highlight_by_language(content,syntax_name)
        ## See: http://ultraviolet.rubyforge.org/svn/lib/uv.rb 
        ## See: http://ultraviolet.rubyforge.org/themes.xhtml
      
        ## User selection of UV Theme
        # Usage: Uv.parse(text, output="xhtml", syntax_name=nil, line_numbers=false, render_style="classic", headers=false)
        if Uv.syntaxes.include? syntax_name
          Uv.parse(content, "xhtml", syntax_name, true,  get_uv_theme_name)#.sub('<pre class=','<span class=').gsub('</pre>','</span>')
        else
          ERB::Util.h(content)
        end
        #Uv.methods.join("\n")# || ::Uv.to_s
        #syntax_name
      end
      
      def theme_name=(val)
         @uv_theme_name = val
      end
      
      def get_uv_theme_name
        #user_theme = User.current.custom_value_for(CustomField.first(:conditions => {:name => 'Ultraviolet Theme'}))
        uv_theme_name = Setting.plugin_redmine_ultraviolet['theme'] || Uv::DEFAULT_THEME
        return uv_theme_name
      end
    end
end


Redmine::SyntaxHighlighting.highlighter = 'UltravioletSyntaxPatch'
#ApplicationHelper.send(:include, UltravioletSyntaxPatch)
