# Carabiner [![Build Status](https://travis-ci.org/mordaroso/carabiner.png)](https://travis-ci.org/mordaroso/carabiner) [![Gem Version](https://badge.fury.io/rb/carabiner.png)](http://badge.fury.io/rb/carabiner)

Rubymotion wrapper for the easy access to the keychain.

![Carabiners](http://upload.wikimedia.org/wikipedia/commons/2/2e/Cheap_carabiners.JPG)

**This gem is still under heavy development and will be released soon. Please be paitent.**

## Installation

Install the gem
```bash
gem install carabiner
```

And add it to your Rakefile
```ruby
require 'carabiner'
```

Or use [Bundler](http://gembundler.com/) to manage your gem dependencies
```ruby
gem 'carabiner'
```

## Usage

First add the Security framwork and the entitlement setting to your Rakefile.

```ruby
app.frameworks += ['Security']

app.entitlements['keychain-access-groups'] = [
  app.seed_id + '.' + app.identifier
]
```

Initialize a keychain item with an unique identifier as a finder hash. If it already exists the keychain data will be available otherwise it will set it up.

```ruby
@item = Carabiner::PasswordItem.new generic: 'YourKeyChainItemIdentifier'
```

After the initialization you have access to all kSecClassGenericPassword attributes with getter and setter methods.
*Note: These values are not secure.*
```ruby
@item.access_group      # The corresponding value is of type CFStringRef and indicates which access group an item is in.
@item.creation_time     # The corresponding value is of type CFDateRef and represents the date the item was created. Read only.
@item.modifaction_date  # The corresponding value is of type CFDateRef and represents the last time the item was updated. Read only.
@item.description       # The corresponding value is of type CFStringRef and specifies a user-visible string describing this kind of item (for example, "Disk image password").
@item.comment           # The corresponding value is of type CFStringRef and contains the user-editable comment for this item.
@item.creator           # The corresponding value is of type CFNumberRef and represents the item's creator. This number is the unsigned integer representation of a four-character code (for example, 'aCrt').
@item.type              # The corresponding value is of type CFNumberRef and represents the item's type. This number is the unsigned integer representation of a four-character code (for example, 'aTyp').
@item.label             # The corresponding value is of type CFStringRef and contains the user-visible label for this item.
@item.is_invisible      # The corresponding value is of type CFBooleanRef and is kCFBooleanTrue if the item is invisible (that is, should not be displayed).
@item.is_negative       # The corresponding value is of type CFBooleanRef and indicates whether there is a valid password associated with this keychain item. This is useful if your application doesn't want a password for some particular service to be stored in the keychain, but prefers that it always be entered by the user.
@item.account           # The corresponding value is of type CFStringRef and contains an account name. Items of class kSecClassGenericPassword and kSecClassInternetPassword have this attribute.
@item.service           # The corresponding value is a string of type CFStringRef that represents the service associated with this item. Items of class kSecClassGenericPassword have this attribute.
@item.generic           # The corresponding value is of type CFDataRef and contains a user-defined attribute. Items of class kSecClassGenericPassword have this attribute.
```

Set and get the secure password
```ruby
@item.password = 'secure'
@item.password
```

And then save the item to the keychain.
```ruby
@item.save!
```

To delete the data use ```@item.delete!``` or ```@item.reset!```.

## Documentation

See Apples [Keychain Services Reference](https://developer.apple.com/library/mac/documentation/Security/Reference/keychainservices/Reference/reference.html) for more information

## TODOs

* Better Documentation
* OSX Support
* Secure Notes
* Certificates
* Keys

Feel free to fork and submit pull requests!