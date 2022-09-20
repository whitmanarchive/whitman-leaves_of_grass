class TeiToEsCluster < TeiToEs

  def get_id
    cluster_id = @xml["id"].gsub("ppp.", "cluster_")
    "#{@filename}.#{cluster_id}"
  end

  def category2
    "cluster"
  end
end
