require 'csv'
require 'highline'

highline = HighLine.new($stdin, $stderr)

patterns = File.read('merchants.re').strip.split("\n").map { |row| row.split(':', 2) }

categories = %w(
FOOD
COFFEE
STUFF
TRAVEL
ENTERTAINMENT
FEES
SERVICES
OTHER
)

data = File.read(ARGV.shift).strip
CSV.parse(data) do |row|
  type = row[7]

  next unless type == 'Purchase'

  date = row[5]
  amount = -(row[6].to_f * 100).to_i
  note = row[8]

  category = patterns.detect do |cat, regex|
    Regexp.new(regex).match?(note)
  end&.first

  unless category
    # category = highline.ask("What is #{note} (#{amount / 100}$)? ")
    highline.choose do |menu|
      menu.index = :letter
      menu.index_suffix = ') '

      menu.prompt = "What is #{note} (#{amount / 100}$)? "
      menu.choices(*categories) do |cat|
        category = cat
        while true
          pattern = highline.ask("Enter pattern to save?")
          break if pattern == ''
          if Regexp.new(pattern).match?(note)
            patterns << [cat, pattern]
            File.open('merchants.re', 'a+') { |f| f.puts("#{cat}:#{pattern}") }
            break
          end
        end
      end
    end
    # regex = highline.ask("Pattern for #{note}? ")
  end

  puts [date, amount, category || note].join(', ')
end
