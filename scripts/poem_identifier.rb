#!/usr/bin/env ruby

require "nokogiri"

source_files = Dir[File.join(__dir__, "../source/tei/**/*.xml")]

source_files.each do |file|
  xml = File.open(file) { |f| Nokogiri::XML(f) }
  # removes custom Whitman TEI namespace, will use id instead of xml:id
  xml.remove_namespaces!

  poems = xml.xpath("//lg[@type='poem']")
  poems_with_ids = xml.xpath("//lg[@type='poem' and boolean(@id)]")

  puts "Reading poem: #{File.basename(file)}"
  puts "    Has #{poems.length}"
  puts "    Missing ids for #{poems.length - poems_with_ids.length}"
end


# add existing ids to a list we can check for duplicates in

