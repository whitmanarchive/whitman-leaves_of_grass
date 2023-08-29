require_relative "../../../whitman-scripts/scripts/ruby/get_works_info.rb"
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
      "creator" => "//sourceDesc/biblStruct/monogr/author",
      "dates" => {
        "not_before" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@from",
        "not_after" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@to",
        "display" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date",
        "default" => "/TEI/teiHeader/fileDesc/sourceDesc/biblStruct/monogr/imprint/date/@when"
      },
      "image_id" => ["./preceding-sibling::pb/@facs", "./parent::node()/preceding-sibling::pb/@facs"],
      "publisher" => "//biblStruct/monogr/imprint/publisher",
      "rights_holder" => "//publicationStmt/distributor",
      "source" => {
        "date" => "//biblStruct/monogr/imprint/date",
        "publisher" => "//biblStruct/monogr/imprint/publisher",
        "pubplace" => "//biblStruct/monogr/imprint/pubPlace",
        "title" => "//biblStruct/monogr/title",
      },
      "title_main" => "//head[@type='main-authorial']",
      "title_edition" => "//sourceDesc/biblStruct/monogr/title",
      "title_article" => "//head/title",
      "title_newspaper" => "//head[@type='main-authorial']/bibl/publisher",
      "text" => "."
    }
  end

  def annotations_text
  end

  def category
    "Published Writings"
  end

  def cover_image
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

  def format
    # TODO
  end

  def keywords
  end

  def language
    "en"
  end

  def person
    []
  end

  # def places
  # end

  # def recipient
  # end

  def source
    s_date = get_text(@xpaths["source"]["date"])
    s_publ = get_text(@xpaths["source"]["publisher"])
    s_pubp = get_text(@xpaths["source"]["pubplace"])
    s_title = get_text(@xpaths["source"]["title"])

    s = "#{s_title}. #{s_pubp}"
    s = "#{s}: #{s_publ}" if s_publ && !s_publ.empty?
    s = "#{s}, #{s_date}" if s_date && !s_date.empty?
  end

  def category2
    "Published Writings / Leaves of Grass"
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
    section_xml.xpath("//hi").each {|hi|
      hi.replace(Nokogiri::XML::Text.new(hi.text, hi.document))
    }
    # make sure the rest of the text doesn't squish together
    resulting_text << Datura::Helpers.normalize_space(section_xml.xpath("//text()").to_a.join(" "))
    Datura::Helpers.normalize_space(resulting_text.join(" "))[0..900000]
  end

  # def works
  # end

  def citation
    # WorksInfo is get_works_info.rb in whitman-scripts repo
    @works_info = WorksInfo.new(xml, @id)
    ids, names = @works_info.get_works_info
    citations = []
    
    if ids && ids.length > 0
      ids.each_with_index do |id, idx|
        name = names[idx]
        citations << {
          "id" => id,
          "title" => name,
          "role" => "whitman_id"
        }
      end
    end
    citations
  end

  def extent
    "entire work"

  end

  def has_part
    poems = @xml.xpath("//lg[@type='poem' and @id and contains(@id, 'ppp')]")
    clusters = @xml.xpath("//lg[@type='cluster']")
    parts = []
    poems.each do |poem_xml|
      poem = TeiToEsPoem.new(poem_xml, {}, nil, @filename)
      parts << {
        "role" => "contained poem",
        "id" => poem.get_id,
        "title" => poem.title
      }
    end
    clusters.each do |cluster_xml|
      cluster = TeiToEsCluster.new(cluster_xml, {}, nil, @filename)
      parts << {
        "role" => "contained cluster",
        "id" => cluster.get_id,
        "title" => cluster.title
      }
    end
    parts

  end

  def has_part
    poems = @xml.xpath("//lg[@type='poem' and @id and contains(@id, 'ppp')]")
    clusters = @xml.xpath("//lg[@type='cluster']")
    parts = []
    poems.each do |poem_xml|
      poem = TeiToEsPoem.new(poem_xml, {}, nil, @filename)
      parts << {
        "role" => "contained poem",
        "id" => poem.get_id,
        "title" => poem.title
      }
    end
    clusters.each do |cluster_xml|
      cluster = TeiToEsCluster.new(cluster_xml, {}, nil, @filename)
      parts << {
        "role" => "contained cluster",
        "id" => cluster.get_id,
        "title" => cluster.title
      }
    end
    parts
  end

end
