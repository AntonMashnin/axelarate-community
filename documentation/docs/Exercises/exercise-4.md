# Упражнение 4
Перенос UST из Terra в EVM-совместимые цепочки через Terra CLI и Axelar Network CLI

## Уровень
Средний

## Отказ от отвественности
!> :fire: Axelar Network находится в стадии разработки. Ни в коем случае Вы не должны передавать какие-либо реальные активы с помощью Axelar. Используйте только те токены тестовой сети, которые Вы не боитесь потерять. Axelar не несет ответственности за какие-либо активы, потерянные, замороженные или невозвратные в любом состоянии или состоянии. Если Вы обнаружите проблему, отправьте ее в этот репозиторий, следуя шаблону.


## Предварительные требования
- Выполните все шаги из руководства [Установка с помощью Docker](/setup/setup-with-docker.md) или [Установка из исходного кода](/setup/setup-with-binaries.md)
- Golang (Следуйте [официальной документации](https://golang.org/doc/install) для выполнения установки)
- Для Ubuntu/Debian систем: установите build-essential пакет с помощью команды `apt-get install build-essential`

## Полезные ссылки
- [Axelar кран](http://faucet.testnet.axelar.dev/)
- Последняя версия docker образа: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Extra commands to query Axelar Network state](/resources/extra-commands.md)

## Присоединитесь к тестовой сети Axelar

Следуйте руководству по [Установке Docker](/setup/setup-with-docker.md) или [Установка из исходного кода](/setup/setup-with-binaries.md) чтобы убедиться, что Ваш узел обновлен, и Вы получили несколько тестовых монет на свой счет.

## Присоединитесь к Terra тестнету

1. В новом окне терминала клонируйте репозиторий terra из Github:
```bash
git clone https://github.com/terra-money/core/
cd core
git checkout v0.5.11
```
2. Выполните установку из исходного кода
```bash
make install
```
3. Убедитесь, что он правильно установлен:
```bash
terrad version --long
```

 > :bulb: If you get `-bash: terrad: command not found`, make sure you do the following:
 > 
 >```bash
 >export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
 >source .profile
>```

4. Инициализация ноды

 [moniker] можете использовать любое имя, которое Вам нравится
 ```bash
terrad init [moniker]
```
5. Используйте любой текстовый редактор, чтобы открыть `$HOME/.terra/config/client.toml`, отредактируйте `chain-id` и `node` поля
```bash
chain-id = "bombay-12"
node = "tcp://adc1043f1d76249009c417dcad0bc807-1055950820.us-east-2.elb.amazonaws.com:26657"
```
Убедитесь, что у Вас есть доступ к тестовой сети, Вы увидите последнюю информацию о блоке
```bash
terrad status
 ```
6. Создайте пару ключей

 `[terra-key-name]` can be any name you like
```bash
terrad keys add [terra-key-name]
```
7. Запросите токены через кран

  - Перейдите к крану terra testnet и получите немного UST для Вашего вновь созданного адреса https://faucet.terra.money/
  - Убедитесь, что токены пришли на Ваш кошелёк
  - `[address]` это адрес, который Вы создали на шаге 6, связанный с [terra-key-name]
 ```bash
terrad q bank balances [address]
```

## Инструкции по отправке UST из тестовой сети Terra в совместимые с EVM цепочки
Этот процесс работает для любых цепочек, совместимых с EVM, которые поддерживает Axelar. Мы используем Ethereum Ropsten в качестве примера.

> ### :bulb: Docker или. установка из исходного кода
>Для следующих команд терминала `axelard`:
>* **Docker:** Команды следует вводить в окружении, прикрепленное к контейнеру `axelar-core`, через
>```
>  docker exec -it axelar-core sh
>```
>* **Бинарные файлы:** Команды должны указывать путь к двоичному файлу `axelard` и флаг `--home`.
>
>  Пример: вместо `axelard keys show validator -a` используйте
>  ```
>   ~/.axelar_testnet/bin/axelard keys show validator -a --home ~/.axelar_testnet/.core
>  ```

1. Создайте депозитный адрес в сети Axelar (на который Вы будете вносить монеты позже)
используя достаточно финансируемый адрес [axelar-key-name].
[адрес получателя] — это адрес, которым Вы управляете в цепочке EVM получателя.
Именно сюда в конечном итоге будет отправлен ваш UST.
```bash
axelard tx axelarnet link [evm chain] [receipent address] uusd --from [axelar-key-name]
```
т.е.,
```bash
axelard tx axelarnet link ethereum 0x4c14944e080FbE711D29D5B261F14fE4E754f939 uusd --from validator
```
Вы должны увидеть `successfully linked [Axelar Network deposit address] и [receipent address]`


> :bulb: Если Вы получите `Error: rpc error: ... not found: key not found`, проверьте это
> `[axelar-key-name]` адрес правильный и достаточно финансируется:
>```bash
>axelard q bank balances [axelar-key-name]
>```

2. Отправить перевод IBC из тестовой сети Terra в Axelar Network
Вернитесь к терминалу с установленным terrad

 ```bash
terrad tx ibc-transfer transfer transfer [Terra channel id] [Axelar Network deposit address] --packet-timeout-timestamp 0 --packet-timeout-height "0-20000" [amount]uusd --gas-prices 0.15uusd --from [terra-key-name] -y -b block
```
Вы можете найти `Terra channel id` в [Testnet релизе](/resources/testnet-releases.md)

 [terra-key-name] это тот, который Вы создали на шаге 6 выше

Подождите ~30-60 секунд, чтобы ретранслятор передал Вашу транзакцию.

?> Если Ваш перевод занимает много времени, Вы можете проверить, истек ли срок его действия и был ли он возвращен на [explorer](https://finder.terra.money/) введя свой terra  адрес и повторить попытку перевода.

3. Переключитесь в терминал Axelard, убедитесь, что Вы получили средства
```bash
axelard q bank balances [Axelar Network deposit address]
```
     Вы должны увидеть баланс с номиналом, начинающимся с `ibc` e.g.:
    ```bash
    balances:
    - amount: "1000000"
     denom: ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F
    ```

4. Подтвердить транзакцию депозита
 - [txhash] это из шага 2
 - [amount] и [token] такие же, как в шаге 2 выше
 - [Axelar Network deposit address] это адрес Выше, на который вы отправили депозит
 ```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]"[token]" [Axelar Network deposit address] --from [axelar-key-name]
```
т.е.,
```bash
axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752  1000000"ibc/6F4968A73F90CF7DE6394BF937D6DF7C7D162D74D839C13F53B41157D315E05F" axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
```

5. Создавайте переводы в цепочке, совместимой с evm, и подписывайте
```bash
axelard tx evm create-pending-transfers [chain] --from [key-name] --gas auto --gas-adjustment 1.2
axelard tx evm sign-commands [chain] --from [key-name] --gas auto --gas-adjustment 1.2
```
т.е.
```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Вы должны увидеть `successfully started signing batched commands with ID {batched commands ID}`.

6. Получить данные команды, которые необходимо отправить в транзакции для выполнения монетного двора
```bash
axelard q evm batched-commands [chain] {batched commands ID from step 5}
```
т.е.
```bash
axelard q evm batched-commands ethereum 1d097247c283cfaca76ad1de4f3a2e5d4d075d99664e5d87aa187a331e8546e7
```
Дождитесь статуса `status: BATCHED_COMMANDS_STATUS_SIGNED` и скопируйте `execute_data`

7. Отправьте транзакцию, упаковывающую данные команды, для создания.

- Откройте свой кошелек Metamask, перейдите в «Настройки» -> «Дополнительно»., затем найдите «Показать данные HEX» и включите эту опцию. Таким образом, Вы можете отправить транзакцию данных напрямую с кошелька Metamask.

- Перейти в метамаск и отправьте транзакцию на `Gateway smart contract address`, вставить шестнадцатеричный код из `execute_data` выше в поле Hex Data

  Имейте в виду, не передавать никакие токены! Чтобы снизить вероятность ошибок при заключении договора, мы рекомендуем
   установить более высокий лимит газа, например 1000000, выбрав Изменить на экране подтверждения.

  (Обратите внимание, что "To Address" — это адрес смарт-контракта Axelar Gateway, который Вы можете найти в разделе [Testnet релизе](/resources/testnet-releases.md))

Теперь вы можете открыть Metamask, выбрать "Активы", затем "Импортировать токены", затем "Пользовательский токен",
и вставьте адрес контракта токена axelarUST (см. [Testnet Релиз](/resources/testnet-releases.md) и найдите соответствующий адрес токена).


>Если Вы еще не видите токены в MetaMask,
>затем проверьте, успешно ли прошла транзакция в [Ropsten проводнике](https://ropsten.etherscan.io) для Вашего [адреса получателя].
>Also, check that the contract executed without any errors (look under the `To:` field on the explorer for that transaction).

## Отправить обратно в Terra
1. Создайте депозитный адрес в сети, совместимой с evm.
```bash
axelard tx evm link [chain] terra [terra address] uusd --from [key-name]
```
т.е.
```bash
axelard tx evm link ethereum terra terra1syhner2ldmm7vqzkskcflaxl6wy9vn7m873vqu uusd --from validator
```
Вы должны увидеть `successfully linked [Ethereum Ropsten deposit address] и [Terra address]`

2. Внешний: отправить упакованные токены в [Ethereum Ropsten депозит адрес] (т.е. с Metamask). Вам нужно иметь немного эфира тестовой сети Ropsten на адресе для отправки транзакции. Дождитесь 30-ти подтверждений в блокчейне. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Подтвердить транзакцию
```bash
axelard tx evm confirm-erc20-deposit [chain] [txID] [amount] [deposit address] --from [key-name]
```
Здесь сумма должна быть указана в uusd, 1UST = 1000000uusd
т.е.,
```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```

Дождитесь подтверждения транзакции.
Вы можете найти его, используя:
- При использовании docker, `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`
- При использовании бинарного файла, `tail -f $HOME/.axelar_testnet/logs/axelard.log | grep -a -e "deposit confirmation"`

4. Маршрут ожидает передачи IBC в сети Axelar
```bash
axelard tx axelarnet route-ibc-transfers --from [key-name] --gas auto --gas-adjustment 1.2
```
Подождите ~30-60 секунд, пока ретранслятор передаст Вашу транзакцию.

5. Вернитесь к терминалу с установленным terrad, убедитесь, что Вы получили ust

 [terra-address] is the address you used above
 ```bash
terrad q bank balances [terra-address]
```
