---
id: e5
sidebar_position: 5
sidebar_label: Упражнение 5
slug: /exercises/e5
---
# Упражнение 5
Перенос активов из Axelar Network в EVM-совместимые сети и обратно через командную строку Axelar Network.

## Уровень
Средний

## Отказ от ответственности
:::предупреждение Axelar Network находится в стадии разработки. Ни в коем случае нельзя передавать какие-либо реальные активы с помощью Axelar. Используйте только те токены тестовой сети, которые Вы не боитесь потерять. Axelar не несет ответственности за потерянные активы, или их заморозку или за токены которые не подлежат восстановлению в любом состоянии. Если Вы обнаружите проблему,пожалуйста, сообщите о ней используя данный репозиторий, следуя шаблону.
:::

## Предварительные требования
- Выполните все шаги из этого руководства [Установка при помощи Docker(a)](/setup-docker) или [Установка из исходного кода](/setup-binaries)
- Установите кошелек Ethereum и получите адрес Ethereum, на котором есть средства для выполнения транзакций. (Вы также можете использовать [Chrome плагин](https://chrome.google.com/webstore/detail/mew-cx/nlbmnnijcnlegkjjpcfjclmcfggfefdm?hl=en))
- У вас должно быть несколько токенов `uaxl` на Вашем сетевом адресе Axelar. Вы можете получить токены AXL здесь [Axelar кран](http://faucet.testnet.axelar.dev/).

## Полезные ссылки
- [Axelar кран](http://faucet.testnet.axelar.dev/)
- Последняя версия Docker образа: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- [Дополнительные команды для получения состояния сети Axelar](/extra-commands)

## Что Вам понадобиться
- Metamask
- Ethereum Ropsten адрес (сгенерированный в Metamask)

## Присоединитесь к тестовой сети Axelar

Используйте руководство для [Настройки среды с помощью Docker](/setup-docker) или [настройки из исходного кода](/setup-binaries) убедитесь, что Ваш сервер обновлен, и Вы получили несколько тестовых монет на свою учетную запись валидатора.

### Отправка монет с Axelar сети в сеть Ethereum 

Далее,в качестве примера мы предположим, что имя Вашей учетной записи Axelar `validator`.  Это имя по умолчанию для учетной записи, которая автоматически создается для Вас, когда Вы впервые присоединяетесь к тестовой сети Axelar.

1. Убедитесь, что у Вас положительный баланс на Вашем аккаунте

```bash
axelard q bank balances $(axelard keys show validator -a)
```
Вы можете увидеть свой баланс т.е.,
```bash
balances:
- amount: "1000000"
 denom: uaxl
```
2. Создайте адрес депозита в сети Axelar (на который, позже, Вы будете вносить монеты)

[token] is `uaxl`.

[Адрес получателя Ethereum Ropsten] это адрес, на который Вы получите токены
```bash
axelard tx axelarnet link ethereum [Ethereum Ropsten receipent address] [token] --from validator
```
Вы должны увидеть `successfully linked [Axelar Network deposit address] and [Ethereum Ropsten dst addr]`

3. Отправьте токен в сети Axelar на указанный Выше адрес депозита.
```bash
axelard tx bank send validator [Axelar Network deposit address] [amount]"[token]"
```

4. Подтвердите депозит транзакцию

[txhash] из приведенной выше команды

[amount] и [token] такие же значения, как в шаге 3

[Axelar Network deposit address] это адрес, указанный выше, на котором выполнялось пополнение депозита

```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]"[token]" [Axelar Network deposit address] --from validator
```
т.е.,
```bash
axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752  1000000uaxl axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
```

5. Сделайте подпись и переводы на Ethereum
```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
```

```bash
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Вы должны увидеть `successfully started signing batched commands with ID {batched commands ID}`.

6. Get the command data that needs to be sent in an Ethereum transaction in order to execute the mint
```bash
axelard q evm batched-commands ethereum {batched commands ID from step 5}
```
Дождитесь `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`

7. Отправьте Ethereum транзакцию, обернув данные команды выполнив

- Откройте свой кошелек Metamask, перейдите в Настройки -> Дополнительно, затем найдите Показать данные HEX и включите эту опцию. Таким образом, вы можете отправить транзакцию с данными напрямую через кошелек Metamask.

- Перейти в Метамаск, отправить транзакцию на `Адрес смарт-контракта шлюза`, вставить hex из `execute_data` из вышеупомянутого поля Hex Data

  Помните, что нельзя передавать токены!

  (Обратите внимание, что "To Address" - это адрес смарт-контракта шлюза Axelar, который Вы можете найти здесь [Testnet релиз](/testnet-releases))

Теперь вы можете открыть Metamask, выберите "Активы", затем "Импорт Токена", затем "Пользовательский токен", и вставьте адрес контракта токена Ethereum (см. [Testnet релиз](/testnet-releases) и найдите соответствующий адрес токена).

Теперь Вы должны увидеть [количество] токенов в своей учетной записи Ethereum Ropsten Metamask.

### Сожгите обернутые ERC20 токены и отправьте их обратно в сеть Axelar

1. Создайте адрес в Ethereum сети

[token] то, что вы получили раньше, `uaxl`

```bash
axelard tx evm link ethereum axelarnet $(axelard keys show validator -a) [token] --from validator
```
Вы должны увидеть `successfully linked [Ethereum Ropsten deposit address] and [Axelar Network dst addr]`

2. Внешний: отправить завернутые токены [на Ethereum Ropsten адрес] (т.е. с Metamask(a)). Для отправки транзакций на Вашем кошельке должен быть тестовой эфириум в сети Ropsten. Подождите 30 подтверждений блока Ethereum. YВы можете следить за состоянием своего депозита с помощью проводника тестовой сети: https://ropsten.etherscan.io/

3. Подтвердите Ethereum транзакцию

```bash
axelard tx evm confirm-erc20-deposit ethereum [txID] [amount] [Ethereum Ropsten deposit address] --from validator
```
Здесь количество должно быть указано в [токенах] (зависит от того, какой токен Вы отправляете).
(Например, 1photon = 1000000uphoton,  1axl = 1000000uaxl)

[txID] - это хэш Вашей транзакции в сети Ethereum Ropsten, который Вы получили на 2-м шаге.

Например:
```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```

Дождитесь подтверждения транзакции.
Вы можете найти её, используя команду `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`.

4. Выполнить отложенное пополнение в сети Axelar
```bash
axelard tx axelarnet execute-pending-transfers --from validator --gas auto --gas-adjustment 1.2
```
5. Убедитесь, что Вы получили средства
```bash
axelard q bank balances $(axelard keys show validator -a)
```

Вы должны увидеть полученные токены на балансе Вашего кошелька (минус платы за газ)

