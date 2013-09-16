module Carabiner
  class PasswordKeychainItem

    attr_accessor :generic_password_query

    # These are the default constants and their respective types,
    # available for the kSecClassGenericPassword Keychain Item class:
    #
    # See the header file Security/SecItem.h for more details.
    ATTRIBUTES = {
      :access_group => KSecAttrAccessGroup,
      :creation_time => KSecAttrCreationDate,
      :modifaction_date => KSecAttrModificationDate,
      :description => KSecAttrDescription,
      :comment => KSecAttrComment,
      :creator => KSecAttrCreator,
      :type => KSecAttrType,
      :label => KSecAttrLabel,
      :is_invisible => KSecAttrIsInvisible,
      :is_negative => KSecAttrIsNegative,
      :account => KSecAttrAccount,
      :service => KSecAttrService,
      :generic => KSecAttrGeneric,
      :password => KSecValueData
    }

    ATTRIBUTES.keys.each do |key|
      attr_accessor key
    end

    NoErr = 0

    def initialize identifier, accessGroup = nil
      self.generic_password_query = {}
      generic_password_query[KSecClass] = KSecClassGenericPassword
      generic_password_query[KSecAttrGeneric] = identifier

      if !accessGroup.nil? && !Device.simulator?
        generic_password_query[KSecAttrAccessGroup] = accessGroup
      end

      generic_password_query[KSecMatchLimit] = KSecMatchLimitOne
      generic_password_query[KSecReturnAttributes] = KCFBooleanTrue

      tempQuery = NSDictionary.dictionaryWithDictionary generic_password_query
      outDictionaryPtr = Pointer.new(:object)

      if !(SecItemCopyMatching(tempQuery, outDictionaryPtr) == NoErr)
        reset!
        self.generic = identifier

        if !accessGroup.nil? && !Device.simulator?
          generic_password_query[KSecAttrAccessGroup] = accessGroup
        end
      else
        self.keychain_item_data = secItemFormatToDictionary(outDictionaryPtr[0])
      end
    end

    def reset!
      delete! unless keychain_item_data.empty?
      self.account     = ''
      self.label       = ''
      self.description = ''
      self.password    = ''
      true
    end

    def save!
      writeToKeychain
      true
    end

    def delete!
      tempDictionary = dictionaryToSecItemFormat(keychain_item_data)
      result = SecItemDelete(tempDictionary)
      if result != NoErr && result != ErrSecItemNotFound
        raise KeychainReturnCodeException.new "Problem deleting current dictionary.", result
      end
      self.keychain_item_data = {}
      true
    end

    def self.key_accepted? key
      ATTRIBUTES.values.include? key
    end

    private

    def keychain_item_data
      ATTRIBUTES.keys.inject({}) do |memo, getter_name|
        constant = ATTRIBUTES[getter_name]
        value    = send(getter_name)
        memo[constant] = value if value
        memo
      end
    end

    def keychain_item_data=(hash)
      ATTRIBUTES.each do |getter_name, constant|
        send("#{getter_name}=", hash[constant])
      end
    end

    def dictionaryToSecItemFormat dictionaryToConvert
      returnDictionary = NSMutableDictionary.dictionaryWithDictionary dictionaryToConvert
      returnDictionary[KSecClass] = KSecClassGenericPassword
      passwordString = dictionaryToConvert[KSecValueData]

      returnDictionary[KSecValueData] = passwordString.dataUsingEncoding(NSUTF8StringEncoding)
      returnDictionary
    end

    def secItemFormatToDictionary dictionaryToConvert
      returnDictionary = NSMutableDictionary.dictionaryWithDictionary dictionaryToConvert
      returnDictionary[KSecReturnData] = KCFBooleanTrue
      returnDictionary[KSecClass] = KSecClassGenericPassword

      passwordDataPtr = Pointer.new(:object)

      result = SecItemCopyMatching(returnDictionary, passwordDataPtr)
      if result == NoErr
        returnDictionary.delete KSecReturnData
        passwordData = passwordDataPtr[0]
        password = NSString.alloc.initWithBytes(passwordData.bytes, length: passwordData.length, encoding: NSUTF8StringEncoding)
        returnDictionary[KSecValueData] = password
      else
        raise KeychainReturnCodeException.new "Serious error, no matching item found in the keychain.", result
      end

      returnDictionary
    end

    def writeToKeychain
      attributesPtr = Pointer.new(:object)
      if SecItemCopyMatching(generic_password_query, attributesPtr) == NoErr
        query = NSMutableDictionary.dictionaryWithDictionary attributesPtr[0]

        query[KSecClass] = generic_password_query[KSecClass]
        attributes_to_update = dictionaryToSecItemFormat keychain_item_data
        attributes_to_update.delete_if { |key, value| !self.class.key_accepted? key }

        if Device.simulator?
          attributes_to_update.delete KSecAttrAccessGroup
        end

        result = SecItemUpdate(query, attributes_to_update)
        unless result == NoErr
          raise KeychainReturnCodeException.new "Couldn't update the Keychain Item.", result
        end
      else
        result = SecItemAdd(dictionaryToSecItemFormat(keychain_item_data), nil)
        unless result == NoErr
          raise KeychainReturnCodeException.new "Couldn't add the Keychain Item.", result
        end
      end
    end

  end
end