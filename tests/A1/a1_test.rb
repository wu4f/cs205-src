require 'pty'
#require 'pry'
require 'timeout'

require_relative '../test_framework'

@words = %w[The quick brown fox jumps over the lazy dog]

a1_test = ->(directory) {
  Dir.chdir(directory) do
    begin
      binary = attempt_compile
      first_time = play_game(binary, 0)
      second_time = play_game(binary, 1)
      raise "Time value did not increase with delay!" unless second_time.first > first_time.first
    rescue => e
      `rm #{binary}` unless binary.nil?
      raise e
    end
    `rm #{binary}`
  end
}

def find_target_word(prompt)
  @words.each do |word|
    return word unless prompt.match(/(#{word})(:?)[ (\r?\n)]?\Z/).nil?
  end

  raise "Word not found. Prompt:\n#{prompt}"
end

def duplicate_word(found_words, word)
  dup_count = found_words.select{|w| w == word}.length
  if word == "the"
    return (found_words.include?("The") && dup_count > 0) || dup_count > 1
  end
  dup_count > 0
end

def play_game(binary, delay)
  delay ||= 0
  
  PTY.spawn("./#{binary}"){|r, w, pid|
    begin
      Timeout.timeout(30) do
        # Counter to abort if we get caught in an infinite loop.
        # That's probably unnecessary since we raise an error
        # upon seeing duplicate words, but it doesn't hurt.
        i = 0
        found_words = []
        while (found_words.length < 9 && i < 100)
          prompt = get_line_with_delay(r)
          puts prompt
          word = find_target_word(prompt)
          raise "Word \"#{word}\" was given multiple times." if duplicate_word(found_words, word)
          found_words.push(word)
          sleep(delay)
          put_line_with_delay(w, word)
          ++i
        end

        raise "Unable to find all words." unless found_words.length == 9
        sleep(1)
        prompt = get_line_with_delay(r)

        # We should see two numbers
        match_result = prompt.scan(/[0-9]+/).map{|val| val.to_i }

        raise "Unable to find time values. Found: #{match_result.inspect}" unless match_result.length == 1 || match_result.length == 2
        puts "Success!"
        return match_result
      end
    rescue Timeout::Error => e
      PTY.kill(-15, pid)
      raise e
    end
  }
end

#run_on_directory(ARGV.first)

a1_test(ARGV.first)
