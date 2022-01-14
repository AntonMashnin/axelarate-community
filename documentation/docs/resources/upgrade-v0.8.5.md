---
id: upgrade-v0.8.5
sidebar_position: 10
sidebar_label: Upgrade to v0.8.5
slug: /upgrade-v0.8.5
---

# Как обновить узел до версии 0.8.5

:::предупреждение
Пожалуйста, выполните этот процесс обновления до 14:30 UTC пятницы, 26 ноября 2021 года.

По истечении этого времени узлы, на которых запущена любая версия axelar-core до версии 0.8.5, перестанут быть согласованы с тестовой сетью.
:::

Проверить версию 0.7.7 of axelarate-community.  В Вашем локальном axelarate-community репозитории:
```
git pull
git checkout v0.7.7
```

:::Примечание
Все команды терминала в этом документе должны выполняться в вашем локальном репозитории axelarate-community.
:::
## Docker

### Обычные (не валидаторные) узлы

TL;DR
```
docker stop axelar-core
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet.sh --axelar-core v0.8.5
```

Обновление очень просто ---just перезапустите Вашу ноду.  Приведенная Выше команда `cp` создает резервную копию данных Вашей тестовой сети. Если что-то пойдет не так, Вы сможете восстановить состояние Вашего узла из резервной копии.

### Узлы валидатора

TL;DR
```
docker stop axelar-core vald tofnd
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet.sh --axelar-core v0.8.5
./join/launch-validator-tools.sh --axelar-core v0.8.5
```

Как обновление не-валидатор ноды ---just перезапустите свой узел.  Как и выше, команда `cp` создает резервную копию данных Вашей тестовой сети на случай, если что-то пойдет не так.

## Исходный код

### Обычные (не валидаторные) узлы

TL;DR
```
kill -9 $(pgrep -f "axelard start")
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet-with-binaries.sh --axelar-core v0.8.5
```

Как и в случае с докером, команда `cp` создает резервную копию данных Вашей тестовой сети на случай, если что-то пойдет не так.

### Ноды Валидатора

TL;DR
```
kill -9 $(pgrep tofnd)
kill -9 $(pgrep -f "axelard vald-start")
kill -9 $(pgrep -f "axelard start")
cp -r ~/.axelar_testnet ~/.axelar_testnet_backup
./join/join-testnet-with-binaries.sh --axelar-core v0.8.5
./join/launch-validator-tools-with-binaries.sh --axelar-core v0.8.5
```

Как и в случае с докером, команда `cp` создает резервную копию данных Вашей тестовой сети на случай, если что-то пойдет не так.

## Валидаторы: восстановление работоспособного состояния

Вполне вероятно, что описанный выше процесс приведет к тому, что Ваш узел валидатора пропустит несколько блоков.

* Если вы пропустите 6 или более из последних 100 блоков, Ваш статус `missed_too_many_blocks`---see [Пропущено слишком много блоков](/validator-zone/troubleshoot/missed-too-many-blocks).
* Если Вы пропустите 50 или более из последних 100 блоков, Ваш статус `jailed`---see [Unjail](/validator-zone/troubleshoot/unjail) для получения инструкций о том, как исправить это условие.
