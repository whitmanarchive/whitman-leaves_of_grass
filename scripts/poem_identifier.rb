#!/usr/bin/env ruby

require "nokogiri"

@poem_all_ids = []
@poem_duplicate_ids = []

def main
  source_files = Dir[File.join(__dir__, "../source/tei/**/*.xml")]

  source_files.each do |file|
    book = BookOfPoems.new(file)

    # ideally move this into the book class, but I'm too lazy to
    # work out sharing arrays across them
    book.poems.each do |poem|
      next if poem.id.empty?
      if @poem_all_ids.include?(poem.id)
        @poem_duplicate_ids << poem.id
      else
        @poem_all_ids << poem.id
      end
    end
    book.report
  end

  if @poem_duplicate_ids.length > 0
    puts "duplicate ids: #{@poem_duplicate_ids.uniq}"
  end

  # uncomment to see all the current identifiers
  # puts @poem_all_ids.sort
  puts "Final identifier: #{@poem_all_ids.sort.last}"
end

class BookOfPoems
  def initialize(path)
    @path = path
    @xml = File.open(path) { |f| Nokogiri::XML(f) }
    # removes custom Whitman TEI namespace, will use id instead of xml:id
    @xml.remove_namespaces!
  end

  def find_and_create_poems
    lgs = @xml.xpath("//lg[@type='poem' or @type='cluster']")
    lgs.map do |lg|
      Poem.new(lg)
    end
  end

  def poems
    @poems ||= find_and_create_poems
  end

  def poems_with_id
    @poems_with_id ||= poems.select { |p| p.has_id? }
  end

  def poems_without_id
    @poems_without_id ||= poems.reject { |p| p.has_id? }
  end

  def report
    puts "Reading file: #{File.basename(@path)}"
    puts "    Has #{poems.length}"
    puts "    Missing ids for #{poems_without_id.length}"
  end
end

class Poem
  def initialize(element)
    @element = element
  end

  def id
    @id ||= @element.xpath("@id").text
  end

  def has_id?
    !id.empty?
  end
end

main
