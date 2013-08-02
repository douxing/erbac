require "erbac_helper"

describe Erbac do
  it "should return the same" do
    er = Erbac.new
    
    s = "hello, world"
    
    er.same(s) === s
  end
end
