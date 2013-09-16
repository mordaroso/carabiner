class User
  attr_accessor :username, :password

  def initialize
    @keychain = Carabiner::KeychainItemWrapper.alloc.initWithIdentifier 'ExampleAppLoginData'
    load
  end

  def save
    @keychain[KSecAttrAccount] = username
    @keychain[KSecValueData] = password
  end

  def load
    self.username = @keychain[KSecAttrAccount]
    self.password = @keychain[KSecValueData]
  end

  def reset
    self.username = ''
    self.password = ''
    @keychain.reset
  end
end