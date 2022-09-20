class TeiToEsCluster < TeiToEs

  def get_id
    cluster_id = @xml["id"].gsub("ppp.", "cluster_")
    "#{@filename}.#{cluster_id}"
  end

  def category2
    "cluster"
  end

  def title
    label = @xml.at_xpath(".#{@xpaths["title_main"]}")
    if label
      label = label.text
      label.gsub!(/[0-9]+ — /, "")
    else
      label = ""
    end
    label = "Cluster: #{label.downcase.titleize}"
    @year ? "#{label} (#{@year})" : label
  end
end
