class TeiToEsOther < TeiToEs

  # NOTE: please refer to tei_to_es overrides in this directory for most
  # of the behavior related to the "other" content such as essays, imprimaturs,
  # epigraphs, and more

  # TODO need to change datura instead of overriding here
  def assemble_identifiers
    file_id = @id
    # TODO might need to check that this is the ONLY of its type in the document
    @section_type = @xml["type"] || @xml.name
    @json["identifier"] = "#{file_id}.#{@section_type}"
    # TODO maybe leave this in here, because it's nice to see
    # that something is happening
  end

  def keywords
    [ "supporting_content" ]
  end

  def title
    label = "#{@section_type.capitalize} (#{@year})"
  end

  def uri
    # TODO find some way to link to specific sections of supporting materials?
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html"
  end

end
