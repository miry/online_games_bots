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

## Logging

To increase log level, you need to specify the `LOG_LEVEL` env variable. Possible values: debug, info, warn, error

# Docker

```
docker run -v /tmp:/app/tmp -v /tmp/cache:/root/.cache -v /tmp/cache:/var/cache -v /tmp/local:/root/.local -d -e LOG_LEVEL=debug -e SERVERS_JSON='{"lk_de":{"bot":"lords_and_kinghts_v2","email":"user@example.com","password":"SUPER_PASSWORD","server_name":"Deutsch 17","server_url":"http://lordsandknights.com","timeout":25,"actions":["build_first", "send_troops_to_missions"],"buildings":["Stone store","Quarry","Wood store","Lumberjack","Ore store","Ore mine","Keep","Library","Farm","Tavern","Arsenal","Fortifications"]}}' -it miry/online_games_bot sh -c "while [ true ] ; do bundle exec ruby runner.rb ; date; sleep 60; done"
```

## TODO

- Hooks to teamcity via https://github.com/github/github-services/pull/47/files
- Add Logger


