module Carabiner
  describe InternetPasswordItem do
    before do
      @item = InternetPasswordItem.new :server => 'github.com', :protocol => :https
      @item.password = 'secret'
      @item.account  = 'Test'
      @item.authentication_type = :html_form
      @item.save!
    end

    after do
      @item.delete!
    end

    it 'initialize attributes' do
      new_item = InternetPasswordItem.new :server => 'github.com', :protocol => :https
      new_item.account.should == 'Test'
      new_item.password.should == 'secret'
      new_item.server.should   == 'github.com'
      new_item.protocol_sym.should == :https
      new_item.authentication_type_sym.should == :html_form
      new_item.persistent?.should == true
    end

    it 'reset!' do
      @item.reset!
      @item.account.should == ''
      @item.password.should == ''
    end

    it 'delete!' do
      @item.delete!
      @item.account.should == nil
      @item.password.should == nil
      @item.persistent?.should == false
    end
  end
end