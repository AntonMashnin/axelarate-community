# Testnet Настройка Ноды
Инструменты для присоединения к сети Axelar с помощью двоичных файлов для Mac/Linux.

Это руководство займет 30–60 минут разработки и 2–4 часа ожидания синхронизации блокчейна. Учебное пособие включает шаги для присоединения к сети Axelar двумя способами. Установка на основе докера и установка с использованием двоичных файлов. В соответствии с Вашими предпочтениями выполните шаги для одного из двух вариантов.

## Отказ от ответственности
!> :fire: Axelar Network находится в стадии разработки. Ни в коем случае Вы не должны передавать какие-либо реальные активы с помощью Axelar. Используйте только те токены тестовой сети, которые Вы не боитесь потерять. Axelar не несет ответственности за какие-либо активы, потерянные, замороженные или невозвратные в любом состоянии или состоянии. Если Вы обнаружите проблему, отправьте ее в этот репозиторий, следуя шаблону.


## Предварительные требования

- Mac OS или Ubuntu (протестировано на версии 18.04)
- Поддерживаемые архитектуры: arm64 и amd64
- JQ командная строка (`apt-get install jq` на Ubuntu, `brew install jq` на Mac OS)
- Минимальные аппаратные требования: 4 ядра, 8-16GB ОЗУ, 512 GB дискового пространства. Рекомендуемы 6-8 ядер, 16-32 GB ОЗУ, 1 TB+ дискового пространства.

## Полезные ссылки
- [Axelar кран](http://faucet.testnet.axelar.dev/)
- Последняя вресия Docker образа:
  + https://hub.docker.com/repository/docker/axelarnet/axelar-core
  + https://hub.docker.com/repository/docker/axelarnet/tofnd

## Полезные команды


Axelar запустит до трех уникальных процессов. axelar-core, vald и tofnd. Если Вы не используете валидатор, запускается один процесс для axelar-core. Чтобы убить эти процессы

Для axelar-core
```bash
kill -9 $(pgrep -f 'axelard start')
```

Для vald
```bash
kill -9 $(pgrep -f 'axelard vald-start')
```

Для tofnd
```bash
kill -9 $(pgrep tofnd)
```

## Присоединение к тестовой сети Axelar

Клонируйте репозиторий, чтобы использовать скрипты и конфиги:

```bash
git clone https://github.com/axelarnetwork/axelarate-community.git
cd axelarate-community
```

Проверьте правильный тег, чтобы сценарии работали с развертыванием. Найдите правильный тег [здесь](/resources/testnet-releases.md).
```bash
git checkout <release-tag>
```


Определите свой внешний IP-адрес. [Этот сайт может помочь](https://whatismyipaddress.com/). Измените поле `external_address` в файле `join/config.toml` и добавьте порт rpc.

```bash
external_address = "123.123.123.123:26656"
```

У вас должна быть настроена переадресация портов на Вашем роутере. Мы рекомендуем пробросить порты 1317, 26656-26658 and 26660.

Запустите скрипт `./join/join-testnet-with-binaries.sh`
```log
Usage: join-testnet-with-binaries.sh [flags]

Необязательные флаги:
-r, --root           Local directory to store testnet data in (IMPORTANT: this directory is removed and recreated if --reset-chain is set)
--bin-directory      Local directory where the downloaded binaries are stored. Defaults to <root_directory>/bin
--axelar-core       Version of axelar-core docker image to run (Format: vX.Y.Z) (by default latest versions are used)
--tendermint-key     Path to the tendermint private key file. Used for recovering a node.
--validator-mnemonic Path to the Axelar validator key. Used for recovering a node.
--reset-chain        Delete local data to do a clean connect to the testnet (If you participated in an older version of the testnet)
```

После запуска `./join/join-testnet-with-binaries.sh`, you should see the following output:

```yaml
Axelar узел запущен.

Адрес валидатора: axelarvaloper1ttxxytlz377agnvzqhllzxmg7dd76tnrwzyahz


- name: validator
  type: local
  address: axelar1ttxxytlz377agnvzqhllzxmg7dd76tnrwrjc9d
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A+O6nUmpQs1meQLtr2RaG5DExv1nyU9cQJKeAUJNH828"}'
  mnemonic: ""


**Важно** запишите эту mnemonic фразу в надежном месте.
Это единственный способ восстановить Вашу учетную запись, если Вы когда-нибудь забудете свой пароль.

naive segment sword error champion pyramid world spend tool reason sound hub barrel amazing parade ahead lamp flag disorder sunny loop artist almost expire

Не забудьте также сделать резервную копию ключа tendermint (/Users/talalashraf/.axelar_testnet/.core/config/priv_validator_key.json)

Чтобы следить за выполнением, запустите 'tail -f /Users/talalashraf/.axelar_testnet/logs/axelard.log'
Чтобы остановить узел, запустите 'killall -9 "axelard"'
```

 Подождите, пока Ваш узел догонит блоки в сети, прежде чем продолжить.
 Используйте `tail -f $HOME/axelar_testnet/logs/axelard.log` чтобы следить за прогрессом узла (это может занять некоторое время). Ваши журналы будут в `ROOT_DIRECTORY/logs` где `ROOT_DIRECTORY` это то, что Вы прошли через флаг.

Вы можете проверить статус синхронизации, запустив:
 ```bash
curl localhost:26657/status | jq '.result.sync_info'
```

**Вывод:**
 ```json
{
  "latest_block_hash": "0B64D2A0EDAB6CEF229510E52F137130134D94AAD64EACB553D51D01B0D1A446",
  "latest_app_hash": "FA3730F49F491DCFF38687F2603CF154563AFA9C77331AF75340C554CB555EFC",
  "latest_block_height": "17051",
  "latest_block_time": "2021-06-01T23:41:43.161261874Z",
  "earliest_block_hash": "080E6B9FC64778F3E0671E046575D3460984F5B1F584E1F2D467341061C7627A",
  "earliest_app_hash": "E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855",
  "earliest_block_height": "1",
  "earliest_block_time": "2021-05-31T21:05:12.032466392Z",
  "catching_up": true
}
```
Подождите пока значение `catching_up` не станет `false`

## Аккаунт Ethereum в тестовой сети
Axelar подписывает метатранзакции для Ethereum, а это означает, что любая учетная запись Ethereum может отправлять команды выполнения транзакций, если команды подписаны ключом Axelar. В упражнениях все транзакции, связанные с Ethereum, отправляются с адреса `0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A` в тестовой сети Ropsten.

## Сгенерируйте ключ Axelar и получите тестовые токены

Вы можете добавить `$HOME/.axelar_testnet/bin` в качестве пути. Каталог bin будет отличаться в зависимости от Вашего корневого каталога. В качестве альтернативы Вы можете использовать полный путь для запуска исполняемого файла, как указано в инструкциях. Установите для переменной среды `AXELARD_CHAIN_ID` значение `axelar-testnet-barcelona`, Вы можете запустить export `AXELARD_CHAIN_ID=axelar-testnet-barcelona`.

1. По умолчанию узел имеет учетную запись с именем validator. Найдите его адрес:
```bash
$HOME/.axelar_testnet/bin/axelard keys show validator -a --home ~/.axelar_testnet/.core
```
2. Зайдите на кран axelar и получите монеты на адрес Вашего валидатора. (Ваша нода еще не является валидатором для целей этой церемонии; это просто имя учетной записи). http://faucet.testnet.axelar.dev/

3. Убедитесь, что Вы получили средства
```bash
$HOME/.axelar_testnet/bin/axelard q bank balances {output_addr_from_step_2} --home ~/.axelar_testnet/.core
```
т.е:
```bash
$HOME/.axelar_testnet/bin/axelard q bank balances axelar1hk3xagjvl4ee8lpdd736h6wcwsudrv0f5ya2we --home ~/.axelar_testnet/.core
```
 ?> :bulb: Баланс появится только после полной синхронизации с сетью

## Остановить и перезапустить тестовую сеть

Чтобы остановить узел, откройте новый терминал CLI и запустите
```bash
killall axelard
```

Чтобы перезапустить узел, запустите `./join/join-testnet-with-binaries.sh` скрипт снова с теми же флагами, что и в первый раз. НЕ используйте флаг `--reset-chain`, иначе Вашему узлу придется снова синхронизироваться с самого начала (и если Вы не сделали резервную копию своих ключей, они будут потеряны).
