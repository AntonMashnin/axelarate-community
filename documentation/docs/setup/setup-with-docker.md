# Testnet Настройка Ноды
---
Инструменты для присоединения к сети Axelar с помощью докер образов. Для установки из исходного кода посетите [Установка из исходного кода](/setup/setup-with-binaries.md).

Это руководство займет 30–60 минут разработки и 2–4 часа ожидания синхронизации блокчейна.Учебное пособие включает шаги для присоединения к сети Axelar двумя способами. Установка на основе докера и установка с использованием двоичных файлов. В соответствии с Вашими предпочтениями выполните шаги для одного из двух вариантов.

## Отказ от ответственности

!> :fire: Axelar Network находится в стадии разработки. Ни в коем случае Вы не должны передавать какие-либо реальные активы с помощью Axelar. Используйте только те токены тестовой сети, которые Вы не боитесь потерять. Axelar не несет ответственности за какие-либо активы, потерянные, замороженные или невозвратные в любом состоянии или состоянии. Если Вы обнаружите проблему, отправьте ее в этот репозиторий, следуя шаблону.


## Предварительные требования

- Mac OS или Ubuntu (протестировано на версии 18.04)
- [Docker](https://docs.docker.com/engine/install/)
- JQ утилита командной строки (`apt-get install jq` на Ubuntu, `brew install jq` на Mac OS)
- Минимальные аппаратные требования: 4 ядра, 8-16GB ОЗУ, 512 GB дискового пространства. Рекомендуемы 6-8 ядер, 16-32 GB ОЗУ, 1 TB+ дискового пространства.


## Полезные ссылки
- [Axelar краг](http://faucet.testnet.axelar.dev/)
- Последняя вресия Docker образов:
  + https://hub.docker.com/repository/docker/axelarnet/axelar-core
  + https://hub.docker.com/repository/docker/axelarnet/tofnd
- Настройка ноды [walkthrough video](https://youtu.be/QC7Gx-ydTtw) с использованием Docker(a)
  + Выполнено на базовой версии Axelar v0.7.6, будьте осторожны с возможными различиями в рабочем процессе.

## Полезные команды

Узлы Axelar поддерживают до трех док-контейнеров (`axelar-core` для основного механизма консенсуса, `vald` для трансляции транзакций в соответствии с событиями цепочки и `tofnd` для пороговых криптоопераций).
Если Вы не используете узел валидации, Вам нужен только контейнер axelar-core.

Вы можете остановить/удалить эти контейнеры, используя:
```bash
docker stop axelar-core vald tofnd
```

Если Вы видите ошибку, связанную с недостаточным количеством газа в любой момент рабочего процесса, добавьте флаги
```bash
--gas=auto --gas-adjustment 1.2
```

## Присоединение к тестовой сети Axelar

Клонируйте репозиторий, чтобы использовать скрипты и конфиги:

```bash
git clone https://github.com/axelarnetwork/axelarate-community.git
cd axelarate-community
```

Проверьте правильный тег, чтобы сценарии работали с развертыванием. Найдите нужный тег на [Testnet релизе](/resources/testnet-releases.md).
```bash
git checkout <release-tag>
```

Определите свой внешний IP-адрес. [Этот веб-сайт может помочь](https://whatismyipaddress.com/). Измените поле `external_address` в файле `join/config.toml` и добавьте порт rpc.

```bash
external_address = "123.123.123.123:26656"
```

У Вас должна быть настроена переадресация портов на Вашем роутере. Мы рекомендуем пробросить порты 1317, 26656-26658 and 26660.
Запустить скрипт `join/join-testnet.sh`
```log
Usage: join-testnet.sh [flags]

Optional flags:
--axelar-core        Version of axelar-core docker image to run (Format: vX.Y.Z) (Default: scraped from https://axelardocs.vercel.app/testnet-releases)
-r, --root           Local directory to store testnet data in (IMPORTANT: this directory is removed and recreated if --reset-chain is set)
--tendermint-key     Path to the tendermint private key file. Used for recovering a node.
--validator-mnemonic Path to the Axelar validator key. Used for recovering a node.
--reset-chain        Delete local data to do a clean connect to the testnet (If you participated in an older version of the testnet)

```
см. [Testnet релизы](/resources/testnet-releases.md) для получения последних доступных версий образов Docker.

Вы можете получить последнюю версию и сохранить ее в переменных:
```bash
AXELAR_CORE_VERSION=$(curl -s https://raw.githubusercontent.com/axelarnetwork/axelarate-community/main/documentation/docs/testnet-releases.md  | grep axelar-core | cut -d \` -f 4)
echo ${AXELAR_CORE_VERSION}
```

Запустите `join/join-testnet.sh`.  При новой установке (или после `--reset-chain`) Вы должны увидеть следующий вывод:

```yaml
Axelar узел работает.

Адрес валидатора: axelarvaloper1ttxxytlz377agnvzqhllzxmg7dd76tnrwzyahz


- name: validator
  type: local
  address: axelar1ttxxytlz377agnvzqhllzxmg7dd76tnrwrjc9d
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A+O6nUmpQs1meQLtr2RaG5DExv1nyU9cQJKeAUJNH828"}'
  mnemonic: ""


**Важно** запишите эту мнемоник фразу в надежном месте.
Это единственный способ восстановить Вашу учетную запись, если Вы когда-нибудь забудете свой пароль.

naive segment sword error champion pyramid world spend tool reason sound hub barrel amazing parade ahead lamp flag disorder sunny loop artist almost expire

Не забудьте также сделать резервную копию ключа tendermint (/Users/talalashraf/.axelar_testnet/.core/config/priv_validator_key.json)

Чтобы следить за выполнением, запустите 'docker logs -f axelar-core'
Чтобы остановить узел, запустите 'docker stop axelar-core'
```
 Подождите, пока Ваш узел синхронизируется, прежде чем продолжить.
 Используйте `docker logs -f axelar-core` чтобы следить за прогрессом узла (это может занять некоторое время).

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
Подождите, пока `catch_up` не станет `false`

## Запись в файл
По умолчанию докер записывает вывод в stdout и stderr. Вы можете перенаправить журналы в файл для отладки и отчетов об ошибках:
```bash
docker logs -f axelar-core 2&> testnet.log
```
В новом окне терминала Вы можете отслеживать файл журнала в режиме реального времени:
```bash
tail -f testnet.log
```
Если Вы обнаружите, что журнал содержит слишком много лишней информации и Вам трудно найти полезную информацию, Вы можете отфильтровать его следующим образом.
```bash
docker logs -f axelar-core 2>&1 | grep -a -e threshold -e num_txs -e proxies
```

## Аккаунт Ethereum в тестовой сети
Axelar подписывает метатранзакции для Ethereum, а это означает, что любая учетная запись Ethereum может отправлять команды выполнения транзакций, если команды подписаны ключом Axelar.В упражнениях все транзакции, связанные с Ethereum, отправляются с адреса `0xE3deF8C6b7E357bf38eC701Ce631f78F2532987A` в тестовой сети Ropsten.

## Сгенерируйте ключ на Axelar и получите тестовые токены
1. В новом окне терминала введите узел Axelar:
```bash
docker exec -it axelar-core sh
```
2. По умолчанию узел имеет учетную запись с именем validator. Найдите его адрес:
```bash
axelard keys show validator -a
```
3. Обратитесь к крану axelar и получите несколько монет на адрес Вашего валидатора (Ваша нода еще не является валидатором для целей этой церемонии, это просто имя учетной записи). http://faucet.testnet.axelar.dev/

4. Убедитесь, что Вы получили средства
```bash
axelard q bank balances {output_addr_from_step_2}
```
т.е:
```bash
axelard q bank balances axelar1hk3xagjvl4ee8lpdd736h6wcwsudrv0f5ya2we
```

 ?> :bulb: Баланс появится только после полной синхронизации с сетью


## Остановить и перезапустить тестовую сеть
Чтобы выйти из интерфейса командной строки узла Axelar, введите `exit` или Control D.
Чтобы остановить узел, откройте новый терминал CLI и запустите
```bash
docker stop $(docker ps -a -q)
```
Предупреждение: это остановит все запущенные в данный момент контейнеры. Если Вы хотите быть менее неразборчивым в этом, запустите `docker stop {конкретный идентификатор контейнера}`, чтобы остановить один контейнер.

Чтобы перезапустить узел, снова запустите сценарий `join/join-testnet.sh` с теми же параметрами версии `--axelar-core` (и, возможно, `--root`), что и раньше. НЕ используйте флаг `--reset-chain`, иначе Вашему узлу придется снова синхронизироваться с самого начала (и если Вы не сделали резервную копию своих ключей, они будут потеряны).

Чтобы снова войти в CLI узла Axelar
```bash
docker exec -it axelar-core sh
```
