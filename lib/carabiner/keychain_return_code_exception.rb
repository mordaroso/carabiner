module Carabiner
  class KeychainReturnCodeException < Exception

    attr_accessor :return_code

    RETURN_CODES = {
      ErrSecSuccess => {:constant_name => 'ErrSecSuccess', :message => "No error."},
      ErrSecUnimplemented => {:constant_name => 'ErrSecUnimplemented', :message => "Function or operation not implemented."},
      ErrSecParam => {:constant_name => 'ErrSecParam', :message => "One or more parameters passed to the function were not valid."},
      ErrSecAllocate => {:constant_name => 'ErrSecAllocate', :message => "Failed to allocate memory."},
      ErrSecNotAvailable => {:constant_name => 'ErrSecNotAvailable', :message => "No trust results are available."},
      ErrSecAuthFailed => {:constant_name => 'ErrSecAuthFailed', :message => "Authorization/Authentication failed."},
      ErrSecDuplicateItem => {:constant_name => 'ErrSecDuplicateItem', :message => "The item already exists."},
      ErrSecItemNotFound => {:constant_name => 'ErrSecItemNotFound', :message => "The item cannot be found."},
      ErrSecInteractionNotAllowed => {:constant_name => 'ErrSecInteractionNotAllowed', :message => "Interaction with the Security Server is not allowed."},
      ErrSecDecode => {:constant_name => 'ErrSecDecode', :message => "Unable to decode the provided data."}
    }

    def initialize message, return_code
      @return_code = return_code
      super message
    end

    def message
      super + "\nReturn Code: #{constant_name} (#{return_message})"
    end

    def return_message
      if return_code_item
        return_code_item[:message]
      else
        "Keychain return code #{return_code} unknown."
      end
    end

    def constant_name
      if return_code_item
        return_code_item[:constant_name]
      else
        return_code.to_s
      end
    end

    def return_code_item
      RETURN_CODES[return_code]
    end
  end
end