# Redshift Models

This folder contains models that map to our RDS cluster. 

## Development

To get this working on development; you'll need to be able to access `bastion.producthunt.com` with your ssh key.

Run server with env flag `CONNECT_REDSHIFT`

```
CONNECT_REDSHIFT=1 rails s
```

To use in console, you'll need to change `.env.development` 
```
CONNECT_REDSHIFT=1
```

## Usage

Direct usage can be done by the connection in `Redshift::Base` class

```ruby
Redshift::Base.connection.execute <<-SQL
  SELECT * FROM producthunt_production.pages limit 1
SQL
```

## New models

Currently, due to incompatibility with active record 6.1+, AR like models are not supported. Specifically, converting from raw result tuples into objects hangs somewhere.


## Troubleshooting

Bastion fingerprint sometimes get changed. If you receive this error, you may need to clean your `known_hosts` file

Error
```
/Users/zyqxd/.rbenv/versions/2.7.5/lib/ruby/gems/2.7.0/gems/net-ssh-6.1.0/lib/net/ssh/verifiers/always.rb:50:in `process_cache_miss': fingerprint SHA256:... does not match for "bastion.producthunt.com,35.170.93.118" (Net::SSH::HostKeyMismatch)
```

Solution: run ssh command, you'll get prompt
```
SHA256:...
Please contact your system administrator.
Add correct host key in /Users/zyqxd/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /Users/zyqxd/.ssh/known_hosts:7
```

After cleaning your known hosts, you'll need to re-ssh to record the bastion fingerprint