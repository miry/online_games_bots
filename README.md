A simple bot for autobuilding and missions.

== TODO

- Hooks to teamcity via https://github.com/github/github-services/pull/47/files
- Add Logger

== Settings

=== Actions

`build_first` - Create a first building in the list. The order of buidlings get from `:buildings`
`send_troops_to_missions` - Send troops to missions for each castle

Example:

```yaml
miry_us:
  :bot: lords_and_kinghts
  :server_name: USA 6
  :server_url: http://lordsandknights.com/en/
  :actions:
    - build_first
    - send_troops_to_missions
```

=== Buildings

Setup a list allowed to build buildings and the order. Depends on ui version it could be different number for buildings.

```yaml
miry_us:
  :bot: lords_and_kinghts
  :server_name: USA 6
  :server_url: http://lordsandknights.com/en/
  :actions:
    - build_first
  :buildings:
    - 13
    - 12
    - 11
```
