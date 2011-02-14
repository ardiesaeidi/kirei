require 'hpricot'

ELEMENTS = ["div", "a", "b", "br", "em", "i", "li", "ol", "p", "small", "strong", "span", "u", "ul", "img"] 

ELEMENT_ATTRIBUTES = {
        "a" => ["href", "rel"],
        "img" => ["src"]
      }

PROTOCOLS = {
  "a" => {"href" => ["http", "https", "mailto"]},
  "img" => {"src" => ["http", "https", "ftp", :relative]}
}

class Kirei
  
  REGEX_PROTOCOL = /^([A-Za-z0-9\+\-\.\&\;\#\s]*?)(?:\:|&#0*58|&#x0*3a)/i
  
  WHITE_SPACE_ELEMENTS = %w[
          address article aside blockquote br dd div dl dt footer h1 h2 h3 h4 h5
          h6 header hgroup hr li nav ol p pre section ul
        ]
  
  def self.clean(input, config = {})
    Kirei.new(config).clean(input)
  end
  
  def initialize(config = {})
    @config = config # Config::DEFAULT.merge(config)
  end
  
  def clean(input)
    doc = Hpricot(input)
  
    traverse_depth(doc) do |node|
      clean_node(node)
    end
    
    doc.to_html
  end
  
  def clean_node(node)
    
    process_node(node)
    
    # remove node if its not white listed
    if node.elem? && !@config[:elements].include?(node.name)
      # maintain its children before removing it
      node.each_child { |child_node| node.before(child_node.to_html)  }
      
      # maintain whitespace for readability
      del = WHITE_SPACE_ELEMENTS.include?(node.name) ? " " : ""
      node.swap(del)
      
      return
    end
    
    # only elements have attributes 
    return unless node.elem?
    
    # if nothing then get out
    attributes = node.attributes.to_hash
    return if attributes.empty?
        
    # remove non whitelisted attrs and check for whitelisted protocols
    attributes.each do |attr_name, val|
      if !@config[:attributes].has_key?(node.name) || !@config[:attributes][node.name].include?(attr_name.downcase)
        node.remove_attribute(attr_name)
        next
      end
      
      if @config[:protocols].has_key?(node.name)
        protocol = @config[:protocols][node.name]
        
        del = if val.downcase =~ REGEX_PROTOCOL
                !protocol[attr_name].include?($1.downcase)
              else
                !protocol[attr_name].include?(:relative)
              end
                  
        node.remove_attribute(attr_name) if del
      end
    end
  end
  
  def process_node(node)
    
    return if @config[:processors].nil?
    
    @config[:processors].each do |processor|
      processor.call(node)
    end
  end
  
  def traverse_depth(node, &block)
    if node.respond_to?(:children)
      node.each_child { |child_node|  traverse_depth(child_node, &block) }
    end
    
    block.call(node)
  end
end


div_test = %(<div rascal="flats">outer div: <a href="http://wired.com">gotcha</a> <div>div inside outer div: <ul><li>omg ponies</li></ul> <b>way inside div:</b></div></div> outside)
bad = %(omg ponies <img src="http://wired.com/a.jpg" />)

# do a recursive call

def test_trav(node)
    
    if node.respond_to?(:children)
      node.each_child { |child_node|  test_trav(child_node) }
    end
    
    # start clean ing of node
    if node.elem? && node.name == "b"
      node.each_child { |child_node| node.before(child_node.to_html)  }
      node.swap('')
    end 
    
   #p node
end

d = Hpricot(div_test)
test_trav(d)


test_text = lambda do |node|
	node.swap('yes! ') if node.text?
end

cleaned = Kirei.clean(bad,
	{:elements => ELEMENTS,
	:protocols => PROTOCOLS,
	:attributes => ELEMENT_ATTRIBUTES,
	:processors => [test_text]
	})

p bad
p cleaned

