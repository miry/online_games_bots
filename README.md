**THIS PROJECT IS NOT MAINTAINED ANYMORE**

A simple bot for autobuilding and missions. Tested on Linux and MacOS.

## Settings

The config file located in `config/servers.yml`. The structure is simple. First you should specify the custom server name example `lak_us` and bot.

```yaml
lak_us:
  :bot: lords_and_kinghts
```

Now we know what kind of game you want to connect. For Lords and Knights we need to specify the server.

```yaml
lak_us:
  :bot: lords_and_kinghts
  :server_name: USA 6
  :server_url: http://lordsandknights.com/en/
```

- `server_name` is the text name that you can copy from the login page after you inpuit the credentials.
- `server_url` is the login url

### Actions

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

### Buildings

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

## TODO

- Hooks to teamcity via https://github.com/github/github-services/pull/47/files
- Add Logger


