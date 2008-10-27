require File.dirname(__FILE__) + '/../spec_helper'

describe PageVersioning::SnippetHelperExtensions do
  
  it "should return options for snippet preview in correct format" do
    pages = [ 
      mock_model(Page, :contains_snippet? => true, :title => "with snippet"),
      mock_model(Page, :contains_snippet? => false, :title => "without snippet")
    ]
    Page.should_receive(:find).and_return(pages)
    helper.insert_options_for_snippet_preview.should == [ [ "with snippet", pages.first.id ] ]
  end
  
end
  