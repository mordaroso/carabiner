class User
  attr_accessor :username, :password

  def initialize
    @keychain = Carabiner::PasswordItem.new :generic => 'ExampleAppLoginData'
    load
  end

  def save
    @keychain.account  = username
    @keychain.password = password
    @keychain.save!
  end

  def load
    self.username = @keychain.account
    self.password = @keychain.password
  end

  def reset
    self.username = ''
    self.password = ''
    @keychain.reset!
  end
end