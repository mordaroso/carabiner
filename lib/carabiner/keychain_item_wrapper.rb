module Carabiner
  class KeychainItemWrapper

    attr_accessor :keychainItemData, :genericPasswordQuery

    # These are the default constants and their respective types,
    # available for the kSecClassGenericPassword Keychain Item class:
    #
    # See the header file Security/SecItem.h for more details.
    KSecAttrs = [
      KSecAttrAccessGroup,
      KSecAttrCreationDate,
      KSecAttrModificationDate,
      KSecAttrDescription,
      KSecAttrComment,
      KSecAttrCreator,
      KSecAttrType,
      KSecAttrLabel,
      KSecAttrIsInvisible,
      KSecAttrIsNegative,
      KSecAttrAccount,
      KSecAttrService,
      KSecAttrGeneric
    ]

    KSecValues = [
      KSecValueData
    ]

    NoErr = 0

    def initWithIdentifier identifier, accessGroup = nil
      self.genericPasswordQuery = {}
      genericPasswordQuery[KSecClass] = KSecClassGenericPassword
      genericPasswordQuery[KSecAttrGeneric] = identifier

      if !accessGroup.nil? && !Device.simulator?
        genericPasswordQuery[KSecAttrAccessGroup] = accessGroup
      end

      genericPasswordQuery[KSecMatchLimit] = KSecMatchLimitOne
      genericPasswordQuery[KSecReturnAttributes] = KCFBooleanTrue

      tempQuery = NSDictionary.dictionaryWithDictionary self.genericPasswordQuery
      outDictionaryPtr = Pointer.new(:object)

      if !(SecItemCopyMatching(tempQuery, outDictionaryPtr) == NoErr)
        self.reset
        keychainItemData[KSecAttrGeneric] = identifier

        if !accessGroup.nil? && !Device.simulator?
          genericPasswordQuery[KSecAttrAccessGroup] = accessGroup
        end
      else
        self.keychainItemData = secItemFormatToDictionary(outDictionaryPtr[0])
      end

      self
    end

    def []= key, inObject
      raise "Key #{key} not accepted." unless self.class.keyAccepted?(key)
      currentObject = keychainItemData[key]
      if currentObject != inObject
        keychainItemData[key] = inObject
      end
      writeToKeychain
    end

    def [] key
      keychainItemData[key]
    end

    def reset
      if !keychainItemData
        self.keychainItemData = {}
      else
        tempDictionary = dictionaryToSecItemFormat(keychainItemData)
        result = SecItemDelete(tempDictionary)
        if result != NoErr && result != ErrSecItemNotFound
          raise "Problem deleting current dictionary. Result: #{result}"
        end
      end
      keychainItemData[KSecAttrAccount] = ''
      keychainItemData[KSecAttrLabel] = ''
      keychainItemData[KSecAttrDescription] = ''
      keychainItemData[KSecValueData] = ''
    end

    def self.keyAccepted? key
      (KSecAttrs + KSecValues).include? key
    end

    private

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

      if SecItemCopyMatching(returnDictionary, passwordDataPtr) == 0
        returnDictionary.delete KSecReturnData
        passwordData = passwordDataPtr[0]
        password = NSString.alloc.initWithBytes(passwordData.bytes, length: passwordData.length, encoding: NSUTF8StringEncoding)
        returnDictionary[KSecValueData] = password
      else
        raise "Serious error, no matching item found in the keychain."
      end

      returnDictionary
    end

    def writeToKeychain
      attributesPtr = Pointer.new(:object)
      if SecItemCopyMatching(genericPasswordQuery, attributesPtr) == NoErr
        updateItem = NSMutableDictionary.dictionaryWithDictionary attributesPtr[0]

        updateItem[KSecClass] = genericPasswordQuery[KSecClass]
        tempCheck = dictionaryToSecItemFormat keychainItemData
        tempCheck.delete_if { |key, value| !self.class.keyAccepted? key }

        if Device.simulator?
          tempCheck.delete KSecAttrAccessGroup
        end

        result = SecItemUpdate(updateItem, tempCheck)
        unless result == NoErr
          raise "Couldn't update the Keychain Item. Result: #{result}"
        end
      else
        result = SecItemAdd(dictionaryToSecItemFormat(keychainItemData), nil)
        unless result == NoErr
          raise "Couldn't add the Keychain Item. Result: #{result}"
        end
      end
    end

  end
end