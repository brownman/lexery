class GameScreen < AbstractScreen
  def initialize(word=nil)
    super()
    
    @rules = GameRules.new
    @dictionary = Dictionary.new(Game.options['dictionary'])
    word ||= @dictionary.pick
    
    @imaginary_count = Game.options['imaginary_words']
    
    @words = []
    @messages = []
    
    @status = Label.new(10, self.height - 32, "current word: #{word}", :height=>32)
    @score =  Label.new(10, 10, "words: 0", :height=>16)
    @imaginary_label =  Label.new(10, @score.bottom + 2, "imaginary words remaining: #{@imaginary_count}", :height=>16)
    @timer = Timer.new(self.width - 32, 10, Game.options['duration'])
    
    @word_control = WordControl.new(320, 256, word)
    Game.window.text_input = @word_control

    @reset_button = Button.new(@word_control.left, @word_control.bottom + 10, 'reset') do
      @word_control.reset
    end
    
    @ok_button = Button.new(@reset_button.right + 12, @word_control.bottom + 10, 'ok') do
      if @word_control.valid || @imaginary_word
        if @imaginary_word
          @imaginary_count -= 1 
          @imaginary_label.text = "imaginary words remaining: #{@imaginary_count}"
        end
        
        word = @word_control.text
        @words << word
        @score.text = "words: #{@words.length}"
        message word, :color=>(@imaginary_word ? Gosu::Color.new(128, 255,0,0) : nil )
        @word_control.word = word
      end
    end
    
    message "Welcome"
    @timer.start
  end
  
  def draw
    super
    window.draw_quad(0, 0, 0xffffffff, width, 0, 0xffffffff, 0, height, 0xFFF7D9FF, width, height, 0xFFF7D9FF)
    @word_control.draw
    @reset_button.draw
    @ok_button.draw
    @status.draw
    @score.draw
    @imaginary_label.draw
    @timer.draw
    
    @messages.each do |m|
      m.draw
    end
  end
  
  def update
    # todo: make this into an event/listener
    # todo: make this into the rules object
    unless @last_word == @word_control.text 
      @valid_transition = @rules.valid_transition? @word_control.word, @word_control.text
      @valid_word = @dictionary.valid_word? @word_control.text
      @last_word = @word_control.text
      @changed_word = @word_control.word != @word_control.text
      @new_word = !@words.include?(@word_control.text)
      
      @word_control.valid = @valid_transition && @valid_word && @new_word && @changed_word
      @imaginary_word = @valid_transition && @new_word && @changed_word && !@valid_word && @imaginary_count > 0
      
      
      @status.text = if !@changed_word
        "Add, remove, or change one letter to create a new word"
      elsif !@valid_transition
        "You may only add, remove, or change one letter"
      elsif !@valid_word
        "'#{@word_control.text}' is not in the dictionary"
      elsif !@new_word
        "'#{@word_control.text}' has already been used"
      else
        "Click 'ok', or hit 'enter' to use this word"
      end
      
    end
    
    @word_control.update
    @reset_button.update
    @ok_button.update
    @status.update
    @score.update
    @imaginary_label.update
    @timer.update
    
    @messages.each do |m|
      @messages.delete m if m.update == false
    end
    
    if @timer.remaining == 0
      puts "game over"
    end
    
  end
  
  def button_down(id)
    case id
    when Gosu::KbReturn, Gosu::KbEnter then 
      @ok_button.action.call(0,0,0)
    when Gosu::KbEscape then  
      window.next_state = TitleScreen.new
    end
  end
  
  def button_up(id)
    @reset_button.button_up(id)
    @ok_button.button_up(id)
  end
  
  def message(text, options={})
    @messages << FadingMessage.new(320, 256-32, text, options)
  end
end
