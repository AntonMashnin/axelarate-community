### Обзор

В этом документе описываются шаги, необходимые для обеспечения возможности восстановления узла валидатора в случае потери его состояния. Для этого необходимо безопасное резервное копирование следующих данных:

* Tendermint ключ валидатора
* Axelar валидатор mnemonic
* Axelar прокси mnemonic
* Tofnd mnemonic

Помимо данных, описанных выше, также необходимо будет получить *данные для восстановления*, связанные со всеми общими ключами, за обслуживание которых отвечал валидатор.

Инструкции по резервному копированию см. [backup](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/validator-backup.md).

### Восстановление узла Axelar

Чтобы восстановить ключ Tendermint и/или ключ валидатора Axelar, используемый узлом Axelard, Вы можете использовать `--tendermint-key` и `--validator-mnemonic` флаги с `join/join-testnet.sh`:

```
./join/join-testnet.sh --tendermint-key /path/to/tendermint/key/ --validator-mnemonic /path/to/axelar/mnemonic/
```

Если вы используете бинарный файл, Вы можете добавить флаги в бинарный скрипт, как в join-testnet.sh, например:
```bash
./join/join-testnet-with-binaries.sh --tendermint-key /path/to/tendermint/key/ --validator-mnemonic /path/to/axelar/mnemonic/
```

### Данные для восстановления

Данные восстановления хранятся в цепочке и позволяют валидатору восстанавливать созданные им совместно используемые ключи.
Чтобы получить данные восстановления для этих общих ключей, Вам нужно сначала узнать соответствующие идентификаторы ключей.
Чтобы запросить эти идентификаторы ключей в блокчейне — и предполагая, что учетная запись валидатора Axelar уже восстановлена — подключите терминал к контейнеру узла и выполните команду:

```bash
~/scripts # axelard q tss key-shares-validator $(axelard keys show validator --bech val -a)
- key_chain: Bitcoin
  key_id: btc-master
  key_role: KEY_ROLE_MASTER_KEY
  num_total_shares: "5"
  num_validator_shares: "1"
  snapshot_block_number: "23"
  validator_address: axelarvaloper1mx627hm02xa8m57s0xutgjchp3fjhrjwp2dw42
- key_chain: Bitcoin
  key_id: btc-secondary
  key_role: KEY_ROLE_SECONDARY_KEY
  num_total_shares: "5"
  num_validator_shares: "1"
  snapshot_block_number: "56"
  validator_address: axelarvaloper1mx627hm02xa8m57s0xutgjchp3fjhrjwp2dw4
```

В этом примере валидатор участвовал в генерации ключей с идентификаторами `btc-master` и `btc-secondary`.
Теперь с помощью идентификаторов ключей Вы можете получить данные восстановления для ключей:

```bash
axelard q tss recover $(axelard keys show validator --bech val -a) btc-master btc-secondary --output json > recovery.json
```

Приведенная выше команда извлечет информацию о восстановлении для вышеупомянутых ключей и сохранит ее в файле `recovery.json`.
Этот файл будет содержать данные, необходимые для выполнения восстановления общего ресурса.

### Восстановление процесса vald

Чтобы восстановить прокси-ключ Axelar, используемый процессом Vald, вы можете использовать флаг `--validator-mnemonic` с `join/launch-validator.sh` следующим образом:

```bash
./join/join-testnet.sh --proxy-mnemonic /path/to/axelar/mnemonic/
```

### Восстановление состояние Tofnd

Если вы хотите сбросить свой tofnd (например, на новой машине, после неожиданной потери данных и т. д.), Вам придется восстановить свое состояние tofnd. Состояние Тофнда состоит из следующего:
1. **ваш приватный ключ**: Внутренний ключ tofnd, используемый для шифрования данных восстановления. Этот закрытый ключ является производным от мнемоник фразы, которая генерируется автоматически при первом запуске tofnd на Вашем компьютере. Вы должны были безопасно сохранить эту мнемоник фразу, так как это единственная парольная фраза, которую можно использовать для восстановления Ваших общих ключей.
2. **ваши общие ключи**: Данные, которые генерируются, когда вы участвуете в кейгене, и используются для выполнения подписи.

Каждый раз, когда вы участвовали в кейгене, Ваши общие ключи шифровались и сохранялись в блокчейне. Это означает, что Вы можете легко получить свои общие ресурсы, но у Вас должен быть свой закрытый ключ (т. е. запуск tofnd с Вашим мнемоническим кодом), чтобы успешно их расшифровать.

#### Запуск tofnd в контейнерной среде

Чтобы восстановить закрытый ключ tofnd и ваши общие ключи, Вы можете использовать `join/launch-validator.sh` с флагами `--tofnd-mnemonic` и `--recovery-info` следующим образом:

```bash
./join/join-testnet.sh --tofnd-mnemonic <mnemonic file> ---recovery-info <recover json file>
```

1. `<мнемоник файл>`: Файл, содержащий Вашу мнемоник фразу-пароль
2. `<восстановление json файла>`: Информация для восстановления в формате json, которую Вы получаете, выполнив
    ```
    axelard q tss recover $(axelard keys show validator --bech val -a) btc-master btc-secondary --output json > recovery.json
    ```
    после присоединения к Вашему контейнеру валидатора (см. раздел [Восстановление данных](#Recovery_Data)).

#### Запуск tofnd при помощи бинарного файла

Если Вы используете двоичный файл tofnd, выполните следующие действия:
1. Создайте JSON-файл восстановления из процесса vald (см. раздел [Восстановление данных](#Recovery_Data)
2. Скопируйте файл восстановления json в `~/.axelar_testnet/.vald/recovery.json`
3. Перейдите в каталог Вашего двоичного файла tofnd.
4. Создайте папку под названием `.tofnd/`.
5. Создать файл `.tofnd/import` который содержит Вашу мнемоник фразу-пароль.
6. Выполнить tofnd в режиме *import*:
    ```bash
    ./tofnd -m import
    ```
    Вывод должен быть похож на следующий:
    ```
    tofnd listen addr 0.0.0.0:50051, use ctrl+c to shutdown
    Importing mnemonic
    kv_manager cannot open existing db [.tofnd/kvstore/mnemonic]. creating new db
    kv_manager cannot open existing db [.tofnd/kvstore/shares]. creating new db
    Mnemonic successfully added in kv store
    ```
7. Перезапустите vald
8. Теперь вы должны увидеть следующее в журналах tofnd:
    ```bash
    Recovering keypair for party X ...
    Finished recovering keypair for party X
    Recovery completed successfully!
    ```

Теперь Tofnd восстановил закрытый ключ, полученный из Вашей мнемоник фразы, во внутреннюю базу данных tofnd, извлек Ваши доли из блокчейна, расшифровал их с помощью Вашего закрытого ключа и, наконец, сохранил их во внутренней базе данных tofnd. После восстановления Вы можете удалить использованный Вами мнемоник файл, так как он больше не нужен.

**Внимание**: Не забудьте по-прежнему хранить свою мнемоник фразу в автономном безопасном месте для будущего восстановления.
