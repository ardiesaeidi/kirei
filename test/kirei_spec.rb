require "../lib/kirei"

describe Kirei, "clean" do
  
  it "should not allow bogus tags" do
    html = %(<SCRIPT "a='>'" SRC="http://ha.ckers.org/xss.js"></SCRIPT>)
    expected = %(<SCRIPT "a='>'" SRC="http://ha.ckers.org/xss.js">)
    
    Kirei.clean(html).should == expected
  end
  
  it "should not allow forbidden style" do
    html = %(<b>here</b> <b style="width: exp ression(alert('XSS'));">and there</b>)
    expected = %(<b>here</b> <b>and there</b>)

    Kirei.clean(html, :attributes => { "b" => ["style"] }).should == expected
  end

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

    Kirei.clean(html, :processors => [text_processor]).should == expected
  end

  it "should not allow url encoded string" do
    html = %(<a href="http://%6A%61%76%61%73%63%72%69%70%74%3A%61%6C%65%72%74%28%27%67%6F%74%79%6F%75%27%29">test</a>)
    expected = %(<a>test</a>)

    Kirei.clean(html).should == expected
  end
end 