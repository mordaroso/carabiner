module Carabiner
  describe PasswordKeychainItem do
    before do
      @item = PasswordKeychainItem.new :generic => 'TestPasswordItem'
      @item.password = 'secret'
      @item.account  = 'Test'
      @item.save!
    end

    after do
      @item.delete!
    end

    it 'initialize attributes' do
      new_item = PasswordKeychainItem.new :generic => 'TestPasswordItem'
      new_item.account.should == 'Test'
      new_item.password.should == 'secret'
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
    end
  end
end