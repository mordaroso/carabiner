module Carabiner
  describe KeychainReturnCodeException do
    describe 'known return value' do
      before do
        @exception = KeychainReturnCodeException.new "custom message", ErrSecNotAvailable
      end

      it 'has return_message' do
        @exception.return_message.should == 'No trust results are available.'
      end

      it 'has constant_name' do
        @exception.constant_name.should == 'ErrSecNotAvailable'
      end

      it 'has descriptive error message' do
        @exception.message.should == "custom message\nReturn Code: ErrSecNotAvailable (No trust results are available.)"
      end
    end

    describe 'unknown return value' do
      before do
        @exception = KeychainReturnCodeException.new "custom message", 999
      end

      it 'has return_message' do
        @exception.return_message.should == 'Keychain return code 999 unknown.'
      end

      it 'has constant_name' do
        @exception.constant_name.should == '999'
      end

      it 'has descriptive error message' do
        @exception.message.should == "custom message\nReturn Code: 999 (Keychain return code 999 unknown.)"
      end
    end
  end
end