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
    "#{file_id}.#{@section_type}"
  end

  def title
    edition = get_text(@xpaths["title"]["edition"])

    if @section_label == "Review"
      review_title = get_text(@xpaths["title"]["article"])
      newspaper = get_text(@xpaths["title"]["newspaper"])
      "#{@section_label}: \"#{review_title},\" #{newspaper} (#{edition}, #{@year})"
    else
      "#{@section_label}. #{edition} (#{@year})"
    end
  end

  def topics
    [ @section ]
  end

  def uri
    # TODO find some way to link to specific sections of supporting materials?
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html"
  end

  def category2
    @section_type.split(".")[0]
  end

end
