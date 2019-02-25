class TeiToEsPoem < TeiToEs

  # TODO might be better to change the behavior in datura
  def assemble_identifiers
    @json["identifier"] = @xml["id"]
    # TODO maybe leave this in here, because it's nice to see
    # that something is happening
    puts @json["identifier"]
  end

  def preprocessing
    @year = date[/^\d{4}/] if date
  end

  def override_xpaths
    return {
      "date" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when",
      "image_id" => ["./preceding-sibling::pb/@facs", "./parent::node()/preceding-sibling::pb/@facs"],
      "publisher" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/publisher",
      "sources" => {
        "title" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/title",
        "date" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date"
      },
      "title" => "head[@type='main-authorial']",
      "text" => "."
    }
  end

  def id
    @xml["id"]
  end

  def category
    "published_works"
  end

  def date_display
    date
  end

  def image_id
    # Note: don't pull full path because will be pulled by IIIF
    images = @xml.xpath(*@xpaths["image_id"])
    images.first if images
  end

  def source
    s_title = get_text(@xpaths["source"]["title"])
    s_date = get_text(@xpaths["source"]["date"])
    # TODO use as it appears here or just first year like in URL and @when ?
    "#{s_title} (#{s_date})"
  end

  def subcategory
    "leaves_of_grass"
  end

  def title
    label = get_text(@xpaths["title"])
    label = "#{label} (#{@year})" if @year
    label
  end

  def uri
    # TODO this links to the whole document but not a particular poem
    # because the HTML doesn't support it, although we could add that to
    # the XSLT if needed, probably?
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html" if @id = "ppp.00707"
  end


end
