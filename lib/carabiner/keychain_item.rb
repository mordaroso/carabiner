module Carabiner
  class KeychainItem
    attr_accessor :query, :persistent, :identifiers

    def self.attributes(attrs = nil)
      if attrs
        @attributes = attrs
        attr_accessor *attrs.keys
      else
        @attributes ||= {}
      end
    end

    def self.sec_class sec_class = nil
      @sec_class ||= sec_class
    end

    NoErr = 0

    def initialize identifiers
      @identifiers = identifiers
      reset_to_identifiers

      self.query = data
      query[KSecClass] = self.class.sec_class

      if Device.simulator?
        query.delete(KSecAttrAccessGroup)
      end

      query[KSecMatchLimit] = KSecMatchLimitOne
      query[KSecReturnAttributes] = KCFBooleanTrue

      tempQuery = NSDictionary.dictionaryWithDictionary query
      outDictionaryPtr = Pointer.new(:object)
      if !(SecItemCopyMatching(tempQuery, outDictionaryPtr) == NoErr)
        reset!
        self.data = self.data.merge identifiers
        self.persistent = false

        unless Device.simulator?
          query[KSecAttrAccessGroup] = identifiers[:access_group]
        end
      else
        self.persistent = true
        self.data = secItemFormatToDictionary(outDictionaryPtr[0])
      end
    end

    def save!
      writeToKeychain
      self.persistent = true
      true
    end

    def delete!
      if persistent?
        tempDictionary = dictionaryToSecItemFormat(data)
        result = SecItemDelete(tempDictionary)
        if result != NoErr && result != ErrSecItemNotFound
          raise KeychainReturnCodeException.new "Problem deleting current dictionary.", result
        end
        self.persistent = false
      end
      self.data = {}
      true
    end

    def reset!
      delete! unless data.empty?
      reset_to_identifiers
      true
    end

    def self.key_accepted? key
      attributes.values.include? key
    end

    def persistent?
      persistent
    end

    def data
      self.class.attributes.keys.inject({}) do |memo, getter_name|
        constant = self.class.attributes[getter_name]
        value    = send(getter_name)
        memo[constant] = value if value
        memo
      end
    end

    def data=(hash)
      self.class.attributes.each do |getter_name, constant|
        send("#{getter_name}=", hash[constant])
      end
    end

    private

    def reset_to_identifiers
      identifiers.each do |getter_name, value|
        send("#{getter_name}=", value)
      end
    end

    def dictionaryToSecItemFormat dictionaryToConvert
      returnDictionary = NSMutableDictionary.dictionaryWithDictionary dictionaryToConvert
      returnDictionary[KSecClass] = self.class.sec_class
      passwordString = dictionaryToConvert[KSecValueData]

      returnDictionary[KSecValueData] = passwordString.dataUsingEncoding(NSUTF8StringEncoding)
      returnDictionary
    end

    def secItemFormatToDictionary dictionaryToConvert
      returnDictionary = NSMutableDictionary.dictionaryWithDictionary dictionaryToConvert
      returnDictionary[KSecReturnData] = KCFBooleanTrue
      returnDictionary[KSecClass] = self.class.sec_class

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
      if SecItemCopyMatching(query, attributesPtr) == NoErr
        query = NSMutableDictionary.dictionaryWithDictionary attributesPtr[0]

        query[KSecClass] = self.class.sec_class
        attributes_to_update = dictionaryToSecItemFormat data
        attributes_to_update.delete_if { |key, value| !self.class.key_accepted? key }

        if Device.simulator?
          attributes_to_update.delete KSecAttrAccessGroup
        end

        result = SecItemUpdate(query, attributes_to_update)
        unless result == NoErr
          raise KeychainReturnCodeException.new "Couldn't update the Keychain Item.", result
        end
      else
        result = SecItemAdd(dictionaryToSecItemFormat(data), nil)
        unless result == NoErr
          raise KeychainReturnCodeException.new "Couldn't add the Keychain Item.", result
        end
      end
    end
  end
end