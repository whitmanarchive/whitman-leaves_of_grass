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
      "//lg[@type='cluster']" => TeiToEsCluster,
      "//lg[@type='poem' and @id and contains(@id, 'ppp')]" => TeiToEsPoem
    }
  end

  def transform_html
    # this is the usual transformation of the tei files into html
    res_html = exec_xsl(@file_location, @script_html, "html", @out_html, @options["variables_html"])
    source_dir = File.expand_path('..', @file_location)
    original_docs = Datura::Helpers.get_directory_files(source_dir)
    # only create the poems and clusters after all the html files for volumes have been created
    if @file_location == original_docs.last
      html_docs = Datura::Helpers.get_directory_files(@out_html).filter { |name| !name.split("/").last.include?("_")}
      html_docs.each do |filename|
        # create poem and cluster html files by splitting big file
        html = CommonXml.create_html_object(filename)
        transform_clusters(html, filename, @out_html)
        transform_poems(html, filename, @out_html)
      end
    end
    # return so that Datura doesn't break
    res_html
  end

  def transform_clusters(html, filename, output_dir)
    clusters = html.xpath("//span[contains(@class, 'tei_lg_type_cluster')]")
    if clusters.length > 0
      clusters.each do |cluster|
        cluster_id = cluster.attributes["data-xmlid"].value.gsub("ppp.", "cluster.")
        volume_id = filename.split("/").last.delete_suffix(".html")
        new_filename = File.join(output_dir, "#{volume_id}_#{cluster_id}.html")
        File.write(new_filename, cluster.to_html)
      end
    end
  end

  def transform_poems(html, filename, output_dir)
    poems = html.xpath("//span[contains(@class, 'tei_lg_type_poem')]")
    if poems.length > 0
      poems.each do |poem|
        if poem.attributes["data-xmlid"]
          poem_id = poem.attributes["data-xmlid"].value.gsub("ppp.", "poem.")
          volume_id = filename.split("/").last.delete_suffix(".html")
          new_filename = File.join(output_dir, "#{volume_id}_#{poem_id}.html")
          File.write(new_filename, poem.to_html)
        end
      end
    end
  end

end
