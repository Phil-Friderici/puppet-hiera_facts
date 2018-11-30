
# hiera_facts

Hiera 5 backend to include data from hierarchies triggerd by facts.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with hiera_facts](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hiera_facts](#beginning-with-hiera_facts)
    * [Example](#example)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

This hiera backend allows to add hiera based configuration data triggered by
client facts. You can choose which fact should trigger what hierachy levels.
A fact can contain multiple triggers as array or comma separated values.

## Setup

### Setup Requirements

Hiera version 5 is required for this backend to work.

### Beginning with hiera_facts

Make sure this module repository is available to your Puppet masters,
clients will not need to access this module.

# Puppet Master Configuration

All configuration is done in the hierachies hash in hiera.yaml.
The backend is passive as there is no default configuration.

To activate the backend, specify fact(s) and search path(s) to the options hash.
To search through multiple hiera levels, add more paths as a nested hash.

You need to restart the puppetserver service to activate changes in hiera.yaml.


## Example

# Create backend configuration on the Puppet master

Add a configuration like this to your hierachy configuration in hiera.yaml:

```yaml
hierarchy:
  - name: "hiera_facts"
    data_hash: "hiera_facts::facts_backend"
    options:
        hierachies:
          'profile_fact':
            fact: 'profile_fact'
            path: "/etc/puppetlabs/code/environments/%{environment}/hieradata/profiles"
          'team_fact':
            fact: 'team_fact'
            path: "/etc/puppetlabs/code/environments/%{environment}/hieradata/team/%{team}/fact"

```

Restart the puppetserver service.

Create or move your hiera files in the according directory structure.

---

# Specify Facts on the Puppet client

Add a key / value pair to the external facts file containg the groups you want to apply.

/etc/puppetlabs/facter/facts.d/example.txt:
```
profile_fact=base,net,webserver
team_fact=webteam
```

Run puppet agent and smile ;)


## Usage

One use case for the backend is to act as a client controlled ENC.
Use hiera to create roles and profiles like configurations and choose them
directly by setting facts on the client itself. That creates an convenient way
for non-Puppeteers to use Puppet by editing a simple text file on the client.

## Limitations

You can use Puppet to rollout clients facts that will then trigger this backend.
It will take two Puppet runs to get them active. The first will just rollout the
facts to the client. The second run will finally start using them.
