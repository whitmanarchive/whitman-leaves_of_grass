class FileTei < FileType

  def subdoc_xpaths
    # match subdocs against classes
    return {
      "//epigraph" => TeiToEsOther,
      "//div1[@type='essay' or @type='preface']" => TeiToEsOther,
      "//titlePart[@type='imprimatur']" => TeiToEsOther,
      "//div3[@type='letter' or @type='article']" => TeiToEsOther,
      "//lg[@type='poem' and @id and contains(@id, 'ppp')]" => TeiToEsPoem
    }
  end

end
