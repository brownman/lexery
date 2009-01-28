class Game
  class << self
    attr_accessor :window
    attr_accessor :options_set
    attr_accessor :default_font
    
    def state
      window.state
    end
    
    def load_image(name, options=[])
      @images ||= {}
      @images[name] ||= Gosu::Image.new window, File.join(GAME_ROOT,'images', name), *options
    end
    
    def load_sound(name)
      @sounds ||= {}
      @sounds[name] ||= Gosu::Sample.new window, File.join(GAME_ROOT, name)
    end
    
    def load_font(name, size)
      @fonts ||= {}
      name = (Game.default_font || Gosu.default_font_name) if name == :default
      @fonts[[name,size]] ||= Gosu::Font.new window, name, size
    end
    
    def options_set
      @options_set ||= 'short game'
    end
    
    def all_options
      @options ||= YAML.load_file(File.join(GAME_ROOT, 'options.yml'))
    end
    
    def options
      all_options[options_set]
    end
    
    def db
      unless @db
        db_path = File.join(GAME_ROOT, 'game.db')
        new_db = !File.exists?(db_path)
        @db = Sequel.sqlite(db_path)
        
        if new_db
          Round.create_table
        end
        
        wordlist = File.join(GAME_ROOT, 'wordlists', 'words.db')
        @db << "attach '#{wordlist}' as wordlist"
      end
      @db
    end
    
  end
end