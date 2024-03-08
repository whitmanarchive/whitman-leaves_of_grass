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
    if @options["threads"] != 1
       puts "threads must be set to 1 to generate html"
       exit 1
    end
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
          transform_other(html, filename, @out_html)
        end
    end
    # return so that Datura doesn't break
    res_html
  end

  def transform_html_sections
  end

  def transform_clusters(html, filename, output_dir)
    clusters = html.xpath("//span[contains(@class, 'tei_lg_type_cluster')]")
    if clusters.length > 0
      clusters.each do |cluster|
        #get the preceding page image with link and put it at the front
        image = cluster.xpath("preceding::a[img]").last
        cluster.first_element_child.before(image)
        cluster_id = cluster.attributes["data-xmlid"].value.gsub("ppp.", "")
        volume_id = filename.split("/").last.delete_suffix(".html")
        new_filename = File.join(output_dir, "#{volume_id}_#{cluster_id}.html")
        new_html = cluster.to_html.encode('UTF-8')
        File.write(new_filename, new_html)
      end
    end
  end

  def transform_poems(html, filename, output_dir)
    poems = html.xpath("//span[contains(@class, 'tei_lg_type_poem')]")
    if poems.length > 0
      poems.each do |poem|
        #get the preceding page image with link and put it at the front
        image = poem.xpath("preceding::a[img]").last
        poem.first_element_child.before(image)
        if poem.attributes["data-xmlid"]
          poem_id = poem.attributes["data-xmlid"].value.gsub("ppp.", "")
          volume_id = filename.split("/").last.delete_suffix(".html")
          new_filename = File.join(output_dir, "#{volume_id}_#{poem_id}.html")
          new_html = poem.to_html.encode('UTF-8')
          File.write(new_filename, new_html)
        end
      end
    end
  end

  # TODO create a proper override that creates the filenames
  def transform_other(html, filename, output_dir)
    paths = ["//span[contains(@class, 'tei_titlePart_type_imprimatur')]", "//div[contains(@class, 'article')]", "//div[contains(@class, 'letter')]", "//div[contains(@class, 'essay')]", "//div[contains(@class, 'preface')]"]
    paths.each do |path|
      other_works = html.xpath(path)
      if other_works.length > 0
        @article_count = 0
        @essay_count = 0
        @letter_count = 0
        other_works.each do |other|
            #get the preceding page image with link and put it at the front
            image = other.xpath("preceding::a[img]").last
            other.first_element_child.before(image)
            other_id = /'(\w*)'/.match(path)[1]
            if other_id == "tei_titlePart_type_imprimatur"
              other_id = "imprimatur"
            end
            #types of material that need to be numbered to match api
            if ["article", "letter"].include?(other_id)
              other_id += ".#{get_count(other_id)}"
            end
            volume_id = filename.split("/").last.delete_suffix(".html")
            new_filename = File.join(output_dir, "#{volume_id}_#{other_id}.html")
            puts new_filename
            new_html = other.to_html.encode('UTF-8')
            File.write(new_filename, new_html)
        end
      end
    end
  end

  private

  def create_html_object(filepath, remove_ns=true)
    file_html = File.open(filepath) { |f| Nokogiri::HTML(f, nil, 'utf-8') }
    file_html.remove_namespaces! if remove_ns
    file_html
  end

  def get_count(name)
    if name == "article"
      @article_count += 1
      return @article_count
    elsif name == "letter"
      @letter_count += 1
      return @letter_count
    elsif name == "essay"
      @essay_count += 1
      return @essay_count
    end
  end
end
