xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "FBA Digest"
    xml.description "News aggregator for FBA and Amazon related articles from the worlds most popular blogs, podcasts and news outlets."
    xml.link root_url

    @posts.each do |post|
      xml.item do
        xml.title "#{post.title} - #{post.source.name} - FBA Digest"
        xml.description post.clean_content
        xml.pubDate post.published.to_s(:rfc822)
        xml.link post.absolute_url
        xml.guid post.absolute_url
        xml.category 'ecommerce'
        xml.category 'amazon'
        xml.category 'amazonfba'
        xml.category 'amazonseller'
        xml.category 'entrepreneurs'
      end
    end
  end
end