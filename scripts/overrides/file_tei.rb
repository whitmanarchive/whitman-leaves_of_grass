class FileTei < FileType

  def subdoc_xpaths
    # match subdocs against classes
    return {
      "//lg[@type='poem']" => TeiToEsPoem
    }
  end

end
