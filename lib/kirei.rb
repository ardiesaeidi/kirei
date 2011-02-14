require "hpricot"
require_relative "kirei/config"

# TODO:
# Make everything a processor (similar to sanitize)
# Make removing cdata, comments configurable
# Revisit need for protocols, just scan styles/src/href for known baddies
# Normalize text in styles/src/href attributes
class Kirei
  
  VERSION = "0.3.0"
  
  REGEX_PROTOCOL = /^([A-Za-z0-9\+\-\.\&\;\#\s]*?)(?:\:|&#0*58|&#x0*3a)/i
  
  def self.clean(input, config = {})
    Kirei.new(config).clean(input)
  end
  
  def initialize(config = {})
    @config = Config::DEFAULT.merge(config)
  end
  
  def clean(input)
    doc = Hpricot(input)
  
    traverse_depth(doc) do |node|
      clean_node(node)
    end
    
    doc.to_html
  end
  
  private
  def clean_node(node)
    
    process_node(node)
    
    # remove node if its not white listed
    if node.elem? && !@config[:elements].include?(node.name)
      # maintain its children before removing it
      node.each_child { |child_node| node.before(child_node.to_html)  }
      
      # maintain whitespace for readability
      del = @config[:whitespace_elements].include?(node.name) ? " " : ""
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
