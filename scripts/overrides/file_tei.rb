class FileTei < FileType

  # xpaths which split apart each TEI file and direct the resulting
  # subdocument to an appropriate class for handling the metadata
  #
  # for example, the contents of <lg type="poem"> would use class TeiToEsPoem
  # to populate the elasticsearch index
  def subdoc_xpaths
    # match subdocs against classes
    {
      "/" => TeiToEs,
      "//epigraph" => TeiToEsOther,
      "//div1[@type='essay' or @type='preface']" => TeiToEsOther,
      "//titlePart[@type='imprimatur']" => TeiToEsOther,
      "//div3[@type='letter' or @type='article']" => TeiToEsOther,
      "//lg[@type='poem' and @id and contains(@id, 'ppp')]" => TeiToEsPoem
    }
  end

end
