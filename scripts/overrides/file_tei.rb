class FileTei < FileType

  def subdoc_xpaths
    # match subdocs against classes
    return {
      "//epigraph" => TeiToEsOther,
      "//div1[@type='essay']" => TeiToEsOther,
      "//titlePart[@type='imprimatur']" => TeiToEsOther,
      "//lg[@type='poem' and @id]" => TeiToEsPoem
    }
  end

end
