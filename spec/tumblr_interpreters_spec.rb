require File.dirname(__FILE__)+"/spec_helper"

require 'numbr5'
require 'tumblr_client'
require File.dirname(__FILE__)+'/../ror_au.example.rb'

describe Tumblr::Interpreters do
  
  TI = Tumblr::Interpreters

  it "should post a flickr link" do
    TI.choose("http://www.flickr.com/photos/lachie/1100849756/","lachie","#ror_au").should == TI.interpreters[0]
  end
  
  it "should post a youtube link" do
    TI.choose("http://youtube.com/watch?v=S7GGkKpBR-g","lachie","#ror_au").should == TI.interpreters[1]
  end

  it "should post a link" do
    TI.choose("http://wherever.com/foo/bar","lachie","#ror_au").should == TI.interpreters[2]
  end
  
  it "should post an image link" do
    TI.choose("http://wherever.com/foo/bar.jpg","lachie","#ror_au").should == TI.interpreters[2]
  end
  
  it "should post a quote" do
    TI.choose("bob: something else","lachie","#ror_au").should == TI.interpreters[3]
  end
  
  it "should post a plain quote" do
    TI.choose("a quote","lachie","#ror_au").should == TI.interpreters[4]
  end
  
  it "should interpret a plain link" do
    TI.interpret(nil,"http://somewhere caption","nick","chan").should == ['link', {
      'url' => "http://somewhere",
      'description' => "caption (nick on chan)" }]
  end
  
  it "should interpret an image link" do
    TI.interpret(nil,"http://somewhere/goatse.png caption","nick","chan").should == ['photo', {
      'source' => "http://somewhere/goatse.png",
      'description' => "caption (nick on chan)" }]
  end
end