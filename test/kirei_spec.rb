require '../lib/kirei'

describe Kirei, "clean" do
  
  it "should preserve whitespace between nodes" do
    html = %(<b>i should be one</b> space away)
    Kirei.clean(html).should == html
  end
  
  it "should strip all non-whitelisted attributes" do
    html = %(<b id="whoops">naughty</b>)
    expected = %(<b>naughty</b>)
    
    Kirei.clean(html).should == expected
  end
  
  it "should allow custom processing" do
    html = %(<b>here</b> there)
    expected = %(<b>here</b> <a href="http://a.com">a.com</a>)
    
    text_processor = lambda do |node|
      node.swap(%( <a href="http://a.com" data="test">a.com</a>)) if node.text? && node.parent.doc?
    end
    
    Kirei.clean(html, { :processors => [text_processor] }).should == expected
  end
  
end 