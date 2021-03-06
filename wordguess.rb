require 'faker'
require 'pp'
require 'pry'
require './cat_ascii.rb'
require 'colorize'

class RandomWord
  attr_accessor :guess, :guessed_letters
  attr_reader  :word_display, :word

# A random word is created based on user input as either a hero, location or quotes
# The word is split into the @letters array
# All letters except special character are switched into underscored "_" and shoveled into the @word_dispaly
# Incorrect guesses are stored into @guess, which is initially set to 0
# Previously guessed letters are stored in @guessed_letters which is initially set as an empty array
# The cat ascii art is printed at the initial position of 0 guesses
  def initialize(level)
    case level
    when "heroes"
      @word = Faker::Overwatch.unique.hero.upcase
    when "locations"
      @word = Faker::Overwatch.unique.location.upcase
    when "quotes"
      @word = Faker::Overwatch.unique.quote.upcase
    end
    @letters = @word.split('')
    @guess = 0
    @word_display = []
    @letters.each do |letter|
      if [" ","!",",",".","?","\"","'",":",";","$"].include?(letter)
        @word_display << letter
      else
        @word_display << "_"
      end
    end
    cat_position
    @guessed_letters = []
  end

# If the "user_letter" is equal to the entire random word, then the player wins
# Else if the "user_letter" is present in the word, the indeces of the correctly guessed letters are stored in letter_indeces
  def letter_index(user_letter)
    letter_indeces =[]
    if user_letter.length > 1
      if user_letter == @word.gsub(/[^0-9A-Za-z]/, '')
        you_win
        letter_indeces = (0...@letters.length).to_a
      end
    else
      @letters.length.times do |i|
        if @letters[i] == user_letter
          letter_indeces << i
        end
      end
    end
    return letter_indeces
  end
# The letter indeces of correctly guessed letters are updated from "_" to their proper letter in @word_display
  def update_display(letter_indeces)
    letter_indeces.each do |index|
      @word_display[index] = @letters[index]
    end
    #puts @word_display
    pretty_print
  end

# The cat ascii art is updated based on the number of missed guesses of the user
  def cat_position
    case @guess
    when 0
      puts cat_0.colorize(:green)
    when 1
      puts cat_1.colorize(:light_green)
    when 2
      puts cat_2.colorize(:yellow)
    when 3
      puts cat_3.colorize(:magenta)
    when 4
      puts cat_4.colorize(:light_red)
    when 5
      puts cat_5.colorize(:red)
    when 10
      puts win_cat_0.colorize(:green)
    when 11
      puts win_cat_1.colorize(:light_green)
    when 12
      puts win_cat_2.colorize(:yellow)
    when 13
      puts win_cat_3.colorize(:magenta)
    when 14
      puts win_cat_4.colorize(:light_red)
    end
  end
# If @word_display does not contain anymore underscores, the user wins
  def did_you_win?
    return !@word_display.include?("_")
  end

#  Prints the word_display array
  def pretty_print
    @word_display.each do |letter|
      print "#{letter} "
    end
    puts ""
  end
# Prints the random_word answer after the user loses
  def secret_word
    puts "Sorry you have failed at this game..."
    puts "Cat thinks you are very delicious."
    puts "The answer was \"#{@word}\""
  end
# Prints the random_word answer after the user wins
  def you_win
    puts "Congrats! You survived"
    puts "The answer was \"#{@word}\""
  end


end # end random_word class

# Will prompt user to re-enter a letter if their input was a number, special character, empty or a previously guessed letter
def check_input(input,letter_array)
  input.gsub!(/[^0-9A-Za-z]/, '')
  until input.to_i == 0 && input != "0" && input != ""
    print "Please enter a letter: "
    input = gets.chomp.upcase
    input.gsub!(/[^0-9A-Za-z]/, '')
  end
  if letter_array.include?(input)
    puts "You have already guessed this letter"
    print "Please try again: "
    input = check_input(gets.chomp.upcase, letter_array)
  end
  return input
end
# Print instruction to game
def welcome_screen
  puts "Welcome to Word Guess!  Let me think of a word first..... ok got it"
  puts "You can guess wrong 5 times until the cat eats you"
end

# Game will run while user enters yes they want to play_again
# User chooses which category of overwatch words they want to guess
# The screen clears and instructions are printed
# An instance of a random_word is created using the user's preferred level as an argument

play_again = true

while play_again

  puts "Hey......do you know Overwatch heroes, locations or quotes best?"
  user_level = gets.chomp
  until ["heroes", "locations", "quotes"].include? user_level
    puts "Valid inputs: heroes, locations, quotes"
    user_level = gets.chomp
  end
  system "clear"
  welcome_screen
  random_word = RandomWord.new(user_level)
# The game runs until the user wins, or they guess wrong 5 times
# After each guess the screen is cleared the directions, cat ascii art and word_display is updated/re-printed
  random_word.pretty_print
  player_win = false
  while random_word.guess < 5 && !player_win
    print "Guess one letter: "
    user_input = check_input(gets.chomp.upcase,random_word.guessed_letters)
    random_word.guessed_letters << user_input
    indeces = random_word.letter_index(user_input)
    if indeces.length > 0
      random_word.update_display(indeces)
    else
      random_word.guess += 1
    end
    system "clear"
    welcome_screen
    random_word.cat_position
    random_word.pretty_print
    if random_word.did_you_win?
      random_word.guess += 10
      system "clear"
      welcome_screen
      random_word.cat_position
      random_word.pretty_print
      random_word.you_win
      player_win = true
    end
  end
  if !random_word.did_you_win?
    random_word.secret_word
  end
# A new game will run again if the user enters yes
# Else the game ends
  print "Would you like to play again? "
  user = gets.chomp
  if user.downcase == "yes"
    play_again = true
  else
    play_again = false
  end
end
