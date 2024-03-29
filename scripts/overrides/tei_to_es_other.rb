class TeiToEsOther < TeiToEs

  # NOTE: please refer to tei_to_es overrides in this directory for most
  # of the behavior related to the "other" content such as essays, imprimaturs,
  # epigraphs, and more

  # TODO need to change datura instead of overriding here
  def get_id
    file_id = @filename
    # TODO might need to check that this is the ONLY of its type in the document
    type = @xml["type"]
    num = @xml["n"]
    ele_name = @xml.name

    @section_type = type || ele_name
    @section_type << ".#{num}" if num
    @section_label = @section_type.capitalize[/[A-Za-z ]+/]
    # articles are actually reviews, so just display them that way
    if @section_label == "Article"
      @section_label = "Review"
    end
    "#{file_id}_#{@section_type}"
  end

  def title
    edition = get_text(@xpaths["title_edition"])
    #commenting out because titles are ridiculously long
    # TODO find a better xpath for newspaper titles
    
    #if @section_label == "Review"
      
      # review_title = get_text(@xpaths["title_article"])
      # newspaper = get_text(@xpaths["title_newspaper"])
      # "#{@section_label}: \"#{review_title},\" #{newspaper} (#{edition}, #{@year})"
    #else
    "#{@section_label}. #{edition} (#{@year})"
    #end
  end

  def category3
    year = date.split("-")[0]
    "Published Writings / Leaves of Grass / #{year}"
  end

  def topics
    [ @section ]
  end

  def uri
    # TODO find some way to link to specific sections of supporting materials?
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html"
  end

  def format
    format = @section_type.split(".")[0]
    if ["letter", "article", "essay"].include?(format)
      format
    end
  end

  def has_part
  end

  def is_part_of
    title = @xml.at_xpath("./ancestor::TEI//titleStmt/title[1]")
    {
      "role" => "containing volume",
      "id" => @filename,
      "title" => title.text
    }
  end

  def extent
  end

end
