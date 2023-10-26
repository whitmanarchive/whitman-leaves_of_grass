class TeiToEsCluster < TeiToEs

  def get_id
    cluster_id = @xml["id"].gsub("ppp.", "")
    "#{@filename}_#{cluster_id}"
  end

  def extent
    "cluster"
  end

  def title
    label = @xml.at_xpath(".#{@xpaths["title_main"]}")
    if label
      label = label.text
      label.gsub!(/[0-9]+ — /, "")
    else
      label = ""
    end
    label = "Cluster: #{label.downcase.titleize}"
    @year ? "#{label} (#{@year})" : label
  end

  def has_part
    poems = @xml.xpath(".//lg[@type='poem' and @id and contains(@id, 'ppp')]")
    parts = []
    poems.each do |poem_xml|
      poem = TeiToEsPoem.new(poem_xml, {}, nil, @filename)
      parts << {
        "role" => "contained poem",
        "id" => poem.get_id,
        "title" => poem.title
      }
    end
    parts
  end

  def is_part_of
    title = @xml.at_xpath("./ancestor::TEI//titleStmt/title[1]")
    {
      "role" => "containing volume",
      "id" => @filename,
      "title" => title.text
    }
  end

  def citation
    # WorksInfo is get_works_info.rb in whitman-scripts repo
    @works_info = WorksInfo.new(@xml, @id)
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
end
