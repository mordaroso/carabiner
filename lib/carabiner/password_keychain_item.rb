module Carabiner
  class PasswordKeychainItem < KeychainItem

    # These are the default constants and their respective types,
    # available for the kSecClassGenericPassword Keychain Item class:
    #
    # See the header file Security/SecItem.h for more details.
    attributes({
                 # The corresponding value is of type CFStringRef and indicates which access group an item is in. Access groups can be used to share keychain items among two or more applications. For applications to share a keychain item, the applications must have a common access group listed in their keychain-access-groups entitlement, and the application adding the shared item to the keychain must specify this shared access-group name as the value for this key in the dictionary passed to the SecItemAdd function.
                 # An application can be a member of any number of access groups. By default, the SecItemUpdate, SecItemDelete, and SecItemCopyMatching functions search all the access groups an application is a member of. Include this key in the search dictionary for these functions to specify which access group is searched.
                 # A keychain item can be in only a single access group.
                 access_group: KSecAttrAccessGroup,

                 # The corresponding value is of type CFDateRef and represents the date the item was created. Read only.
                 creation_time: KSecAttrCreationDate,

                 # The corresponding value is of type CFDateRef and represents the last time the item was updated. Read only.
                 modifaction_date: KSecAttrModificationDate,

                 # The corresponding value is of type CFStringRef and specifies a user-visible string describing this kind of item (for example, "Disk image password").
                 description: KSecAttrDescription,

                 # The corresponding value is of type CFStringRef and contains the user-editable comment for this item.
                 comment: KSecAttrComment,

                 # The corresponding value is of type CFNumberRef and represents the item's creator. This number is the unsigned integer representation of a four-character code (for example, 'aCrt').
                 creator: KSecAttrCreator,

                 # The corresponding value is of type CFNumberRef and represents the item's type. This number is the unsigned integer representation of a four-character code (for example, 'aTyp').
                 type: KSecAttrType,

                 # The corresponding value is of type CFStringRef and contains the user-visible label for this item.
                 label: KSecAttrLabel,

                 # The corresponding value is of type CFBooleanRef and is kCFBooleanTrue if the item is invisible (that is, should not be displayed).
                 is_invisible: KSecAttrIsInvisible,

                 # The corresponding value is of type CFBooleanRef and indicates whether there is a valid password associated with this keychain item. This is useful if your application doesn't want a password for some particular service to be stored in the keychain, but prefers that it always be entered by the user.
                 is_negative: KSecAttrIsNegative,

                 # The corresponding value is of type CFStringRef and contains an account name. Items of class kSecClassGenericPassword and kSecClassInternetPassword have this attribute.
                 account: KSecAttrAccount,

                 # The corresponding value is a string of type CFStringRef that represents the service associated with this item. Items of class kSecClassGenericPassword have this attribute.
                 service: KSecAttrService,

                 # The corresponding value is of type CFDataRef and contains a user-defined attribute. Items of class kSecClassGenericPassword have this attribute.
                 generic: KSecAttrGeneric,

                 # Data attribute key. A persistent reference to a credential can be stored on disk for later use or passed to other processes.
                 # The corresponding value is of type CFDataRef.  For keys and password items, the data is secret (encrypted) and may require the user to enter a password for access.
                 password: KSecValueData
               })

    sec_class KSecClassGenericPassword

    def reset!
      super
      self.account     = ''
      self.label       = ''
      self.description = ''
      self.password    = ''
      true
    end

  end
end