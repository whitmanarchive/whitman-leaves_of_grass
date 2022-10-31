#!/usr/bin/env ruby

require "nokogiri"

puts %(
Before running this script, which was written
very hastily and not robustly, you will
want to run `poem_identifier.rb` to get the final
identifier available, then use that value + 1
with this script in the format ppp.00000
)

puts "Continue? y/n"

continue = gets.chomp

if continue != "y" && continue != "Y"
  exit
end

puts "What identifier would you like to begin with? ppp.00000 format, please"

input = gets.chomp

if !input.match?(/^ppp\.\d{5}$/)
  puts "Check identifier format, something is wrong"
  exit
end

num = input.slice(/\d{5}$/).to_i

source_files = Dir[File.join(__dir__, "../source/tei/**/*.xml")]

source_files.each do |file|
  xml = File.open(file) { |f| Nokogiri::XML(f) }
  # where no xml:id but type is poem / cluster
  missing_ids = xml.xpath("//xmlns:lg[not(@xml:id) and (@type='poem' or @type='cluster')]")
  puts "file #{File.basename(file)} missing #{missing_ids.length} ids"

  missing_ids.each do |lg|
    lg["xml:id"] = "ppp.#{num.to_s.rjust(5, "0")}"
    num += 1
  end

  # here's the problem...nokogiri changes things like self-closing
  # tags, so it kinda borks up the files. Not sure what you want to do
  # but I can print out the text of the poems if you'd rather they were
  # done by hand!
  File.write(file, xml.to_xml)

end
