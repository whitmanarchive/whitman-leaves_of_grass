require "titleize"

class TeiToEsPoem < TeiToEs

  # NOTE: please refer to tei_to_es overrides in this directory for most
  # of the behavior related to the poem content of leaves of grass

  # TODO might be better to change the behavior in datura

  def preprocessing
    @cluster = @xml.at_xpath("./parent::lg[@type='cluster']")
  end

  def get_id
    if !@xml["id"]
      return nil
    end

    poem_id = @xml["id"].gsub("ppp.", "")
    "#{@filename}_#{poem_id}"
  end

  def get_first_line
    # grab the first 7 words in the first line of the poem, since there
    # are no poem titles in this edition, or return nil if line is not found
    line = @xml.at_xpath(".//l")
    line.text.split(" ")[0..6].join(" ") if line
  end

  def category3
    year = date.split("-")[0]
    "Published Writings / Leaves of Grass / #{year}"
  end

  def title
    # majority of editions simply grab identified poem title
    label = @xml.at_xpath(".#{@xpaths["title_main"]}")
    if label
      label = label.text
      label.gsub!(/[0-9]+ — /, "")
    else
      label = ""
    end

    # for two editions, will need to do something fancier for title
    if @filename == "ppp.00271"
      # need to get the opening lines for 1855 edition
      opening = get_first_line
      if opening
        label = "Leaves of Grass, \"#{opening}\""
      else
        label = "Leaves of Grass, Untitled Poem"
      end

    elsif @filename == "ppp.01500" || @filename == "ppp.00473"
      # need to get the poem cluster's title if poem doesn't have title
      if label[/^\d+\.?/] || label == ""
        cluster = @xml.at_xpath("./parent::lg[@type='cluster']//head[@type='main-authorial']")
        if label == ""
          # if there is no label at all, we need to try to get the index of this particular poem
          siblings = @xml.xpath("./preceding-sibling::lg[@type='poem']")
          label = siblings.length + 1
        end
        label = "#{cluster.text} #{label}" if cluster
      end
      label.gsub!(".", "")
    end
    label = label.downcase.titleize
    @year ? "#{label} (#{@year})" : label
  end

  def topics
    [ "Poem" ]
  end

  def uri
    # TODO at some point these will be linking to individual poem pages instead
    # of poems within the entire edition, but that day is not today
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html##{@xml["id"]}"
  end

  def extent
    "poem"
  end

  def has_part
  end

  def is_part_of
    title = @xml.at_xpath("./ancestor::TEI//titleStmt/title[1]")
    parts = [{
      "role" => "containing volume",
      "id" => @filename,
      "title" => title.text
    }]
    if @cluster
      cluster_id = @cluster["id"].gsub("ppp.", "cluster.")
      cluster_title = @cluster.at_xpath(".#{@xpaths["title_main"]}")
      parts << {
        "role" => "containing cluster",
        "id" => "#{@filename}_#{cluster_id}",
        "title" => cluster_title.text
      }
    end
    parts
  end

  def previous_item
    prev_node = @xml.at_xpath("./preceding::lg[@type='poem'][1]")
    if prev_node
      poem = TeiToEsPoem.new(prev_node, {}, nil, @filename)
      prev_id = poem.get_id
      prev_title = poem.title
      {
        "role" => "previous poem",
        "id" => prev_id,
        "title" => prev_title
      }
    end
  end

  def next_item
    next_node = @xml.at_xpath("./following::lg[@type='poem'][1]")
    if next_node
      poem = TeiToEsPoem.new(next_node, {}, nil, @filename)
      next_id = poem.get_id
      next_title = poem.title
      {
        "role" => "next poem",
        "id" => next_id,
        "title" => next_title
      }
    end
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
