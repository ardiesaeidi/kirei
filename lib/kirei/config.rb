class Kirei
  module Config
    DEFAULT = {
      :elements => ["a", "b", "br", "em", "i", "li", "ol", "p", "small", "strong", "span", "u", "ul", "img"],

      :attributes => {
              "a" => ["class", "href", "rel"],
              "img" => ["class", "src"]
            },
            
      :protocols => {
          "a" => {"href" => ["http", "https", "mailto"]},
          "img" => {"src" => ["http", "https", "ftp", :relative]}
        },
        
      :processors => [],
      
      :whitespace_elements => %w[
              address article aside blockquote br dd div dl dt footer h1 h2 h3 h4 h5
              h6 header hgroup hr li nav ol p pre section ul
            ]
    }
  end
end