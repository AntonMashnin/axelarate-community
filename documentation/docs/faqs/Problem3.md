# c2d2cli контейнер выдает ошибку некоректного IP-адреса

## Проблема 
При запуске c2d2cli докер выдает ошибку некоректного IP-адреса.
```bash
~/axelar/axelarate-community$ ./c2d2/c2d2cli.sh --version v0.3.0 Copying config.toml to /home/mirrormirage0/.c2d2cli docker: Error response from daemon: invalid IP address in add-host: "host-gateway". See 'docker run --help'
```

## Прична
Версия Docker(а) устарела

## Решение
Обновите докер до версии 20 или выше
