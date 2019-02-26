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

  def keywords
    # TODO adding in order to have way to discern types of content for LoG
    [ "poem" ]
  end

  def title
    if @id == "ppp.00271"
      # grab the first 7 words in the fisrt line of the poem, since there
      # are no poem titles in this edition
      line = @xml.at_xpath(".//l")
      if line
        opening = line.text.split(" ")[0..6].join(" ")
        "Leaves of Grass, \"#{opening}\", #{@year}"
      else
        "Leaves of Grass, Untitled Poem, #{@year}"
      end
    else
      # majority of editions simply grab identified poem title
      label = get_text(@xpaths["title"]["main"])
      "#{label} (#{@year})" if @year
    end
  end

  def uri
    # TODO at some point these will be linking to individual poem pages instead
    # of poems within the entire edition, but that day is not today
    "#{@options["site_url"]}/published/LG/#{@year}/whole.html##{@xml["id"]}"
  end

end
