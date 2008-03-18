require File.dirname(__FILE__)+"/spec_helper"

require 'numbr5'
require 'tumblr_client'
require File.dirname(__FILE__)+'/../ror_au.example.rb'

describe Numbr5::Sessions::Quoting do
  before do
    @client = mock(:client)
    @nick = 'numbr5'
    @text = 'something'
    @chan = '#roro'
    
    @messages = [
      ['lachie','line1'],
      ['andy'  ,'line2'],
      
      # span start:
      ['lachie','line3'],
      ['andy'  ,'line4'],
      ['lachie','line5'],
      ['andy'  ,'line6'],
      ['lachie','line7'],
      ['andy'  ,'line8'],
      ['lachie','line9'],
      ['andy'  ,'line10'],
      ['lachie','line11'],
      ['andy'  ,'line12']
    ]
    
    @client.stub!(:messages).and_return(@messages)
    
    @q = Numbr5::Sessions::Quoting.new @client,@nick,@text,@chan
  end
  
  it "should quit" do
    @client.should_receive(:remove_session).and_return(@nick)
    @q.process(@client,'q','lachie','numbr5')
  end

  
  it "should return max_span" do
    @q.max_span.should == 10
  end
  
  it "should calculate initial window start" do
    @q.window_start.should == 2
  end
  
  it "should calculate initial window end" do
    @q.window_end.should == 11
  end
  
  it "should calculate window start" do
    @q.start = 3
    @q.window_start.should == 4
  end
  
  it "should calculate window end" do
    @q.end = 9
    @q.window_end.should == 10
  end
  
  it "should restrict start" do
    @q.start = -1
    @q.start.should == 1
  end
  
  it "should restrict end" do
    @q.end = 11
    @q.end.should == 10
  end
  
  it "should return initial span" do
    @q.span.should == [
      ['lachie','line3'],
      ['andy'  ,'line4'],
      ['lachie','line5'],
      ['andy'  ,'line6'],
      ['lachie','line7'],
      ['andy'  ,'line8'],
      ['lachie','line9'],
      ['andy'  ,'line10'],
      ['lachie','line11'],
      ['andy'  ,'line12']
    ]
  end
  
  it "should return restricted span" do
    @q.start = 4
    @q.end   = 10
    @q.span.should == [
      ['andy'  ,'line6'],
      ['lachie','line7'],
      ['andy'  ,'line8'],
      ['lachie','line9'],
      ['andy'  ,'line10'],
      ['lachie','line11'],
      ['andy'  ,'line12']
    ]
  end
  
  
  it "should show the window" do
    
  end
  
  it "should reset the window" do
    
  end
  
  it "should set the window" do
    
  end
end