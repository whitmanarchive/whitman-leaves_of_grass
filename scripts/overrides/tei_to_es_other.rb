class TeiToEsOther < TeiToEs

  # NOTE: please refer to tei_to_es overrides in this directory for most
  # of the behavior related to the "other" content such as essays, imprimaturs,
  # epigraphs, and more

  # TODO need to change datura instead of overriding here
  def assemble_identifiers
    file_id = @id
    # TODO might need to check that this is the ONLY of its type in the document
    type = @xml["type"]
    num = @xml["n"]
    ele_name = @xml.name

    @section_type = type || ele_name
    @section_type << ".#{num}" if num
    @json["identifier"] = "#{file_id}.#{@section_type}"
  end

  def keywords
    [ "supporting_content" ]
  end

  def title
    authorial = get_text(@xpaths["title"]["other_content"], false, @xml)
    section = @section_type.capitalize[/[A-Za-z ]+/]
    Datura::Helpers.normalize_space("#{section}, #{authorial} (#{@year})")
  end

  def uri
    # TODO find some way to link to specific sections of supporting materials?
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html"
  end

end
