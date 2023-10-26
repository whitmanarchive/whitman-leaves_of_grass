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
        html = create_html_object(filename)
        transform_clusters(html, filename, @out_html)
        transform_poems(html, filename, @out_html)
        # transform_other(html, filename, @out_html)
      end
    end
    # return so that Datura doesn't break
    res_html
  end

  def transform_clusters(html, filename, output_dir)
    clusters = html.xpath("//span[contains(@class, 'tei_lg_type_cluster')]")
    if clusters.length > 0
      clusters.each do |cluster|
        cluster_id = cluster.attributes["data-xmlid"].value.gsub("ppp.", "")
        volume_id = filename.split("/").last.delete_suffix(".html")
        new_filename = File.join(output_dir, "#{volume_id}_#{cluster_id}.html")
        html = cluster.to_html.encode('UTF-8')
        File.write(new_filename, html)
      end
    end
  end

  def transform_poems(html, filename, output_dir)
    poems = html.xpath("//span[contains(@class, 'tei_lg_type_poem')]")
    if poems.length > 0
      poems.each do |poem|
        if poem.attributes["data-xmlid"]
          poem_id = poem.attributes["data-xmlid"].value.gsub("ppp.", "")
          volume_id = filename.split("/").last.delete_suffix(".html")
          new_filename = File.join(output_dir, "#{volume_id}_#{poem_id}.html")
          html = poem.to_html.encode('UTF-8')
          File.write(new_filename, html)
        end
      end
    end
  end

  # TODO create a proper override that creates the filenames
  # def transform_other(html, filename, output_dir)
  #   paths = ["//span[contains(@class, 'tei_titlePart_type_imprimatur')]", "//span[contains(@class, 'tei_div3_type_article')]", "//span[contains(@class, 'tei_div3_type_letter')]", "//span[contains(@class, 'tei_div1_type_essay')]", "//span[contains(@class, 'tei_div1_type_preface')]"]
  #   paths.each do |path|
  #     other_works = html.xpath(path)
  #     if other_works.length > 0
  #       other_works.each do |other|
  #         if other.attributes["data-xmltype"]
  #           poem_id = other.attributes["data-xmlid"].value.gsub("ppp.", "")
  #           volume_id = filename.split("/").last.delete_suffix(".html")
  #           new_filename = File.join(output_dir, "#{volume_id}_#{poem_id}.html")
  #           html = other.to_html.encode('UTF-8')
  #           File.write(new_filename, html)
  #         end
  #       end
  #     end
  #   end
  # end

  private

  def create_html_object(filepath, remove_ns=true)
    file_html = File.open(filepath) { |f| Nokogiri::HTML(f, nil, 'utf-8') }
    file_html.remove_namespaces! if remove_ns
    file_html
  end

end
