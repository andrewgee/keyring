# keyring:  System keyring abstraction library
# License: MIT (http://www.opensource.org/licenses/mit-license.php)

# This is a keyring backend for the libsecret Keyring
# https://wiki.gnome.org/Projects/Libsecret

class Keyring::Backend::LibSecretKeyring < Keyring::Backend
  register_implementation(self)

  def initialize
    require 'gir_ffi'
    GirFFI.setup :Secret

    schema = ::Secret::Schema.new(
      "com.github.jheiss.keyring",
      ::Secret::SchemaFlags::NONE,
      {
        "service": 0, # Secret::SchemaAttributeType::STRING,
        "username": 0, #Secret::SchemaAttributeType::STRING
      }
    )
  rescue LoadError
  end
  def supported?
    defined?(Secret) && true
  end
  def priority
    1
  end

  def set_password(service, username, password)
    attrs = get_attrs_for(service, username)
    name = "#{service} (#{username})"
    Secret.password_store_sync(schema, attrs, Secret.COLLECTION_DEFAULT, name, password, nil)
  end
  def get_password(service, username)
    if item = Secret.password_lookup_sync(schema, get_attrs_for(service, username), nil)
      item
    else
      false
    end
  end
  def delete_password(service, username)
    Secret.password_clear_sync(schema, get_attrs_for(service, username), nil)
  end

  protected

  def get_attrs_for(service, username)
    {
      "service": service.to_s,
      "username": username.to_s
    }
  end
end
