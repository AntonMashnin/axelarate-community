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

[Ethereum Ropsten receipent address] is the address you want to receive the tokens to
```bash
axelard tx axelarnet link ethereum [Ethereum Ropsten receipent address] [token] --from validator
```
Look for `successfully linked [Axelar Network deposit address] and [Ethereum Ropsten dst addr]`

3. Send the token on Axelar Network to the deposit address specified above
```bash
axelard tx bank send validator [Axelar Network deposit address] [amount]"[token]"
```

4. Confirm the deposit transaction

[txhash] is from the above command

[amount] and [token] are the same as in step 3 above

[Axelar Network deposit address] is the address above you deposited to

```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]"[token]" [Axelar Network deposit address] --from validator
```
e.g.,
```bash
axelard tx axelarnet confirm-deposit F72D180BD2CD80DB756494BB461DEFE93091A116D703982E91AC2418EC660752  1000000uaxl axelar1gmwk28m33m3gfcc6kr32egf0w8g6k7fvppspue --from validator
```

5. Create transfers on Ethereum and Sign
```bash
axelard tx evm create-pending-transfers ethereum --from validator --gas auto --gas-adjustment 1.2
```

```bash
axelard tx evm sign-commands ethereum --from validator --gas auto --gas-adjustment 1.2
```
Look for `successfully started signing batched commands with ID {batched commands ID}`.

6. Get the command data that needs to be sent in an Ethereum transaction in order to execute the mint
```bash
axelard q evm batched-commands ethereum {batched commands ID from step 5}
```
Wait for `status: BATCHED_COMMANDS_STATUS_SIGNED` and copy the `execute_data`

7. Send the Ethereum transaction wrapping the command data to execute the mint

- Open your Metamask wallet, go to Settings -> Advanced, then find Show HEX data and enable that option. This way you can send a data transaction directly with the Metamask wallet.

- Go to metamask, send a transaction to `Gateway smart contract address`, paste hex from `execute_data` above into Hex Data field

  Keep in mind not to transfer any tokens!

  (Note that the "To Address" is the address of Axelar Gateway smart contract, which you can find under [Testnet Release](/testnet-releases))

You can now open Metamask, select "Assets", then "Import Token", then "Custom Token", and paste the Ethereum token contract address (see [Testnet Release](/testnet-releases) and look for the corresponding token address).

You should now see [amount] tokens in your Ethereum Ropsten Metamask account.

### Burn ERC20 wrapped tokens and send back to Axelar Network
1. Create a deposit address on Ethereum

[token] is what you minted before, `uaxl`

```bash
axelard tx evm link ethereum axelarnet $(axelard keys show validator -a) [token] --from validator
```
Look for `successfully linked [Ethereum Ropsten deposit address] and [Axelar Network dst addr]`

2. External: send wrapped tokens to  [Ethereum Ropsten deposit address] (e.g. with Metamask). You need to have some Ropsten testnet Ether on the address to send the transaction. Wait for 30 Ethereum block confirmations. You can monitor the status of your deposit using the testnet explorer: https://ropsten.etherscan.io/

3. Confirm the Ethereum transaction

```bash
axelard tx evm confirm-erc20-deposit ethereum [txID] [amount] [Ethereum Ropsten deposit address] --from validator
```
Here, amount should be specific in [token] (depends on what token you are sending).
(For instance, 1photon = 1000000uphoton,  1axl = 1000000uaxl)

[txID] is the Ethereum Ropsten transaction hash of your burn transaction from step 2.

Example:
```bash
axelard tx evm confirm-erc20-deposit ethereum 0xb82e454a273cb32ed45a435767982293c12bf099ba419badc0a728e731f5825e 1000000 0x5CFEcE3b659e657E02e31d864ef0adE028a42a8E --from validator
```

Wait for transaction to be confirmed.
You can search it using `docker logs -f axelar-core 2>&1 | grep -a -e "deposit confirmation"`.

4. Execute pending deposit on Axelar Network
```bash
axelard tx axelarnet execute-pending-transfers --from validator --gas auto --gas-adjustment 1.2
```
5. Verify you received the funds
```bash
axelard q bank balances $(axelard keys show validator -a)
```

You should see the deposited token in your balance (minus gas fees)

