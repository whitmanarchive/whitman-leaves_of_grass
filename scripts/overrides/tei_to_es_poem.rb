require "titleize"

class TeiToEsPoem < TeiToEs

  # NOTE: please refer to tei_to_es overrides in this directory for most
  # of the behavior related to the poem content of leaves of grass

  # TODO might be better to change the behavior in datura
  def assemble_identifiers
    @json["identifier"] = @xml["id"]
    # TODO maybe leave this in here, because it's nice to see
    # that something is happening
    # puts @json["identifier"]
  end

  def get_first_line
    # grab the first 7 words in the fisrt line of the poem, since there
    # are no poem titles in this edition, or return nil if line is not found
    line = @xml.at_xpath(".//l")
    line.text.split(" ")[0..6].join(" ") if line
  end

  def keywords
    # TODO adding in order to have way to discern types of content for LoG
    [ "poem" ]
  end

  def title

    # majority of editions simply grab identified poem title
    label = @xml.at_xpath(@xpaths["title"]["main"])
    if label
      label = label.text
      label.gsub!(/[0-9]+ — /, "")
    else
      label = ""
    end

    # for two editions, will need to do something fancier for title
    if @id == "ppp.00271"
      # need to get the opening lines for 1855 edition
      opening = get_first_line
      if opening
        label = "Leaves of Grass, \"#{opening}\""
      else
        label = "Leaves of Grass, Untitled Poem"
      end

    elsif @id == "ppp.01500" || @id == "ppp.00473"
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

    label = label.titleize
    @year ? "#{label} (#{@year})" : label
  end

  def uri
    # TODO at some point these will be linking to individual poem pages instead
    # of poems within the entire edition, but that day is not today
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html##{@xml["id"]}"
  end

end
