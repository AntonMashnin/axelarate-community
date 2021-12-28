---
id: e3
sidebar_position: 3
sidebar_label: Упражнение 3
slug: /exercises/e3
---
# Упражнение 3
Перенесите BTC в Axelar Network (как обёрнутый актив) и обратно через интерфейс командной строки Axelar Network.

## Level
Средний

## Отказ от ответственности
:::предупреждение Axelar Network находится в стадии разработки. Ни в коем случае нельзя передавать какие-либо реальные активы с помощью Axelar. Используйте только те токены тестовой сети, которые Вы не боитесь потерять. Axelar не несет ответственности за потерянные активы, или их заморозку или за токены которые не подлежат восстановлению в любом состоянии. Если Вы обнаружите проблему,пожалуйста, сообщите о ней используя данный репозиторий, следуя шаблону.
:::

## Предварительные требования
- Выполните все шаги из этого руководства [Установка при помощи Docker(a)](/setup-docker) или [Установка из исходного кода](/setup-binaries)

## Полезные ссылки
- [Axelar кран](http://faucet.testnet.axelar.dev/)
- Последняя версия Docker образа: https://hub.docker.com/repository/docker/axelarnet/axelar-core
- Упражнение 3 [видео с пошаговым руководством](https://youtu.be/ggngYFa0AnQ) как использовать Docker 
  + Для выполнения задания использовалась версия Axelar v0.7.6, будьте осторожны с потенциальными различиями в рабочем процессе
- [Дополнительные команды](/extra-commands) для получения состояния сети Axelar

## Что Вам понадобиться
- Биткойн кран тестовой сети для отправки тестовых BTC:: https://testnet-faucet.mempool.co/


## Присоединитесь к тестовой сети Axelar

Используйте руководство для [настройки среды с помощью Docker](/setup-docker) или [настройки из исходного кода](/setup-binaries) убедитесь, что Ваш сервер обновлен до последней версии.

## Инструкция создания и сжигание монет
Эти инструкции представляют собой пошаговое руководство, выполнения команд для перемещения актива из исходного места в сеть назначения и обратно. Активы создаются как обернутые активы в сети Axelar. Команды отправляются в сеть Axelar Network, которая отвечает за (а) создания адресов ввода/вывода, (b) маршрутизацию и завершение транзакций, и (c) создание/сжигание соответствующих активов.

Для выполнения этих тестов Вам понадобятся несколько тестовых биткойнов в тестовой сети Биткойн, и адрес получателя Axelar в тестовой сети Axelar Testnet.

### Создание Bitcoin монет в сети Axelar
1. Сгенерируйте новый Axelar адрес
```bash
axelard keys add [key-name]
```
Посетите в Axelar кран и получите несколько монет на свой созданный адрес. http://faucet.testnet.axelar.dev/

Убедитесь, что вы получили средства
```bash
axelard q bank balances [output address above]
```

2. Создайте Bitcoin депозит адрес (на который, позже, Вы внесёте монеты)

[Адрес назначения Axelar Network] это адрес, который Вы создали на шаге 1, связанный с Вашим [key-name]
[key name] это имя, которое Вы использовали на шаге 1
```bash
axelard tx bitcoin link axelarnet [Axelar Network dst addr] --from [key-name]
-> returns deposit address
```

т.е.,
```bash
axelard tx bitcoin link axelarnet axelar1xr04qffe0f0gf4sjzswefx0npadsxfmrs7kry6 --from my-key
```

После этого Вы должны увидеть следующий вывод `successfully linked [bitcoin deposit address] and [Axelar Network dst addr]`

3. Внешний: отправьте несколько ТЕСТОВЫХ BTC в тестовой сети Биткойн на адрес биткоин депозита, указанный выше, и дождитесь 6 подтверждений (в биткойн сети).
- ВНИМАНИЕ: НЕ ОТПРАВЛЯЙТЕ РЕАЛЬНЫЕ АКТИВЫ
- Вы можете использовать биткойн кран, например https://bitcoinfaucet.uo1.net/ отправить ТЕСТОВЫЙ BTC на адрес депозита
- Вы можете следить за состоянием своего депозита с помощью проводника в тестовой сети: https://blockstream.info/testnet/


4. Подтвердите получение биткойна

[key name] это имя, которое Вы использовали на шаге 1
```bash
axelard tx bitcoin confirm-tx-out "[txID:vout]" "[amount]btc" "[deposit address]" --from [key-name]
```

т.е.,

```bash
axelard tx bitcoin confirm-tx-out 615df0b4d5053630d24bdd7661a13bea28af8bc1eb0e10068d39b4f4f9b6082d:0 0.0001btc tb1qlteveekr7u2qf8faa22gkde37epngsx9d7vgk98ujtzw77c27k7qk2qvup --from my-key
```

Дождитесь подтверждения транзакции (~10 Axelar блоков, ~50 секунд).
Вы увидите что-то вроде этого в консоли сервера:

```bash
bitcoin outpoint confirmation result is
```

Вы можете выполнить поиск с помощью
- `docker logs -f axelar-core 2>&1 | grep -a -e outpoint`
- `docker logs -f axelar-core 2>&1 | grep -B 1 -e axelar1... (address from step 1)`

5. Выполнить отложенный депозит в сети Axelar
[key name] это имя, которое Вы использовали на шаге 1
```bash
axelard tx axelarnet execute-pending-transfers --from [key-name] --gas auto --gas-adjustment 1.2
```
6. Проверьте получение монет

[Адрес назначения Axelar Network] это адрес, который Вы создали на шаге 1, связанный с Вашим [key-name]
```bash
axelard q bank balances [Axelar Network dst addr]
```
Вы должны увидеть созданные биткойн сатоши.
```bash
balances:
- amount: "10000"
denom: satoshi
```

### Сожгите обернутые биткойн-токены и получите родные сатоши

Чтобы конвертировать обёрнутый биткойн обратно в биткойн, выполните следующие команды:

1. Создайте Axelar депозит адрес

[key name] это адрес, который Вы создали на шаге 1
```bash
axelard tx axelarnet link bitcoin [destination bitcoin addr] satoshi --from [key-name]
-> returns deposit address
```

т.е.,
```bash
axelard tx axelarnet link bitcoin tb1qtc2rjxezqumzxwe0kucj36k7mf83psa253684k satoshi --from my-key
```

Найдите адрес депозита Axelar в качестве первой строчки вывода в этой строке (`axelar...`):

```bash
successfully linked {axelar12xywfpt5cq3fgc6jtrumq5n46chuq9xzsajj5v} and {tb1qtc2rjxezqumzxwe0kucj36k7mf83psa253684k}
```
:::обратите внимание
Убедитесь, что Вы связали биткойн-адрес, который контролируется Вами, т.е. если Вы свяжете его с адресом, контролируемым Axelar, Ваш вывод будет считаться пожертвованием и добавлен в пул средств
:::

2. отправьте сатоши в сети Axelar на указанный выше адрес депозита

:::подсказка
Пожалуйста, не отправляйте всю сумму, Вам понадобятся сатоши в упражнении 5.
:::
```bash
axelard tx bank send [key-name] [Axelar Network deposit address] [amount]satoshi
```
т.е.,
```bash
axelard tx bank send my-key axelar12xywfpt5cq3fgc6jtrumq5n46chuq9xzsajj5v 5000satoshi
```



3. Подтвердите транзакцию о получении депозита

[txhash] из приведенной выше команды

[amount] такое же, как было отправлено

[key name] это имя, которое Вы использовали на шаге 1

```bash
axelard tx axelarnet confirm-deposit [txhash] [amount]satoshi [Axelar Network deposit address] --from [my-key]
```

Здесь количество должно быть указано в сатоши. (Например, 0.0001BTC = 10000)
т.е.,

```bash
axelard tx axelarnet confirm-deposit 12B7795C49905194C5433E3413AABBF3C6AA27BFD1F20303C66DA4319B143A91 5000satoshi axelar12xywfpt5cq3fgc6jtrumq5n46chuq9xzsajj5v --from my-key
```

Готово! На следующем этапе вывод средств должен быть подписан и отправлен в сеть Биткойн.

:::подсказка
В этом релизе, мы запускаем эти команды примерно раз в день. Так что вернитесь через 24 часа и проверьте баланс на адресе тестовой сети Биткойн, на который Вы отправили вывод средств.
:::


