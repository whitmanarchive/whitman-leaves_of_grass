class TeiToEs < XmlToEs

  # NOTE these overrides apply to all of the leaves of grass subclasses
  # so if you are changing them, make sure that your changes are acceptable
  # for essays, poems, imprimaturs, etc

  def preprocessing
    @year = date[/^\d{4}/] if date
  end

  def override_xpaths
    {
      "contributors" => [
        "/TEI/teiHeader/fileDesc/titleStmt/editor",
        "/TEI/teiHeader/fileDesc/titleStmt/respStmt/persName"
      ],
      "dates" => {
        "not_before" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@from",
        "not_after" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@to",
        "display" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date",
        "default" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"
      },
      "image_id" => ["./preceding-sibling::pb/@facs", "./parent::node()/preceding-sibling::pb/@facs"],
      "publisher" => {
        "name" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/publisher",
        "place" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/pubPlace"
      },
      "rights" => "//publicationStmt/availability",
      "rights_uri" => "//publicationStmt/availability//ref/@target",
      "source" => {
        "title" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/title",
        "date" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date"
      },
      "title" => {
        "main" => "head[@type='main-authorial']",
        "other_content" => "head[@type='main-authorial']/bibl/publisher"
      },
      "text" => "."
    }
  end

  def category
    "published works"
  end

  def image_id
    # Note: don't pull full path because will be pulled by IIIF
    images = @xml.xpath(*@xpaths["image_id"])
    images.first if images
  end

  def date
    dates = @xml.xpath(@xpaths["dates"]["not_before"], @xpaths["dates"]["default"])
    Datura::Helpers.date_standardize(dates.first.text, true) if dates.first
  end

  def date_display
    date = get_text(@xpaths["dates"]["display"])
  end

  def date_not_after
    dates = @xml.xpath(@xpaths["dates"]["not_after"], @xpaths["dates"]["default"])
    Datura::Helpers.date_standardize(dates.first.text, false) if dates.first
  end

  def date_not_before
    date
  end

  # TODO will language always be english?
  def language
    "en"
  end

  def languages
    ["en"]
  end

  def publisher
    if @id == "ppp.00271"
      "No Publisher"
    else
      pub = get_text(@xpaths["publisher"]["name"])
      loc = get_text(@xpaths["publisher"]["place"])
      [pub, loc].reject(&:empty?).join(", ")
    end
  end

  def rights
    get_text(@xpaths["rights"])
  end

  def rights_uri
    get_text(@xpaths["rights_uri"])
  end

  def rights_holder
  end

  def source
    s_title = get_text(@xpaths["source"]["title"])
    s_date = get_text(@xpaths["source"]["date"])
    "#{s_title} (#{s_date})"
  end

  def subcategory
    "Leaves of Grass"
  end

  def text
    resulting_text = []
    resulting_text += text_additional
    # TODO this needs to use traverse to avoid abutting xml tags
    # and insert spaces, but will need to work on the hi replacement
    # below to make sure it isn't replacing the hi node with another
    # type of child node instead

    # create a duplicate version of the @xml to avoid altering it
    section_xml = Nokogiri::XML.parse(@xml.at_xpath(".").to_xml)
    # need to remove "<hi rend='smallcaps'>" type tags to put back together words
    # like L<hi>EAVES OF</hi> G<hi>RASS</hi> => LEAVES OF GRASS
    section_xml.xpath("//hi").each {|hi| hi.replace(hi.children)}
    resulting_text << Datura::Helpers.normalize_space(section_xml.text)
    Datura::Helpers.normalize_space(resulting_text.join(" "))
  end

end
