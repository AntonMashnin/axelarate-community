---
id: evm-key-rotation
sidebar_position: 1
sidebar_label: Ротация EVM ключа
slug: /evm-key-rotation
---
# Ротация Master ключа
1. Принять решение о новом идентификаторе ключа.
```
axelard q tss key-id {chain name} master
```
Соглашение: первый ключ должен иметь имя `{chain name}-master-genesis`.  Последующие ключи будут иметь имена `{chain name}-master-1`, `{chain name}-master-2`, и т.д.  Если вы испортили ключ, сгенерируйте новый ключ с тем же номером, но в конце добавьте букву: `{chain name}-master-1a`, `{chain name}-master-1b`, и т.д.  Пример: для использования Ethereum `eth` для `{chain name}`.

2. Сгенерируйте новый мастер-ключ, на который будет выполнена ротация.
```
axelard tx tss start-keygen --id {key ID} --from validator --gas auto --gas-adjustment 1.2
```
Подождите, пока новый ключ не будет сгенерирован.
Новый ключ успешно сгенерирован, если следующий запрос дает ключевую роль `KEY_ROLE_MASTER_KEY`.
```
axelard q tss key {key ID}
```

3. Создайте команду EVM для передачи права собственности на контракт AxelarGateway.
```
axelard tx evm transfer-ownership {chain name} {key ID} --from validator --gas auto --gas-adjustment 1.2
```

4. Подпишите команду передачи права собственности, которую мы только что создали.
```
axelard tx evm sign-commands {chain name} --from validator --gas auto --gas-adjustment 1.2
```
Подождите, пока подпись не будет доступна.
Команда успешно подписана, если следующий запрос дает статус пакетных команд `BATCHED_COMMANDS_STATUS_SIGNED`. Если по какой-либо причине отображаемый статус `BATCHED_COMMANDS_STATUS_ABORTED`, подпись можно исправить.
```
axelard q evm latest-batched-commands {chain name}
```

5. Сначала найдите адрес шлюза цепочки EVM. Используйте Metamask для отправки транзакции на этот адрес.
```
axelard q evm gateway-address {chain name}
```

Отправьте подписанную команду в цепочку EVM.
```
axelard q evm latest-batched-commands {chain name}
```
Скопируйте поле `execute_data` из запроса выше, вставьте скопированное значение в поле `data` EVM транзакции и отправьте её. Для этого можно использовать Metamask. Убедитесь, что Вы вручную увеличили `газовый лимит` транзакции перед ее отправкой. Используйте по крайней мере 2 000 000 газа, чтобы быть в безопасности.

6. Подтвердите смену права собственности.
Прежде чем инициировать подтверждение, убедитесь, что Вы уже дождались достаточного количества подтверждений (в настоящее время 30) для транзакции. Как только передача права собственности будет успешно подтверждена, система переключится на новый ключ. Обратите внимание, что подтверждение может быть запущено повторно, если вы не дождались достаточного количества подтверждений.
```
axelard tx evm confirm-transfer-ownership {chain name} {tx ID} {key ID} --from validator --gas auto --gas-adjustment 1.2
```
Дождитесь окончания голосования.
Подтверждение и смена ключа успешно завершены, если следующий запрос дает ожидаемый идентификатор ключа.
```
axelard q evm address {chain name} --key-role master
```

# Ротация вторичного ключа
1. Принять решение о новом идентификаторе ключа.
```
axelard q tss key-id {chain name} secondary
```
Соглашение: то же, что и соглашение о главном ключе выше, за исключением заменяемого значения `master -> secondary`.  Например: `eth-secondary-2`.

2. Сгенерируйте новый вторичный ключ для ротации.
```
axelard tx tss start-keygen --id {key ID} --key-role secondary --from validator --gas auto --gas-adjustment 1.2
```
Подождите, пока новый ключ не будет сгенерирован.
Новый ключ успешно сгенерирован, если следующий запрос дает ответ `KEY_ROLE_SECONDARY_KEY`.
```
axelard q tss key {key ID}
```

3. Создайте команду EVM для передачи операторства контракта AxelarGateway.
```
axelard tx evm transfer-operatorship {chain name} {key ID} --from validator --gas auto --gas-adjustment 1.2
```

4. Подпишите команду передачи оператора, которую мы только что создали.
```
axelard tx evm sign-commands {chain name} --from validator --gas auto --gas-adjustment 1.2
```
Подождите, пока подпись не будет доступна.
Команда успешно подписана, если следующий запрос покажет статус `BATCHED_COMMANDS_STATUS_SIGNED`. Если по какой-либо причине отображаемый статус `BATCHED_COMMANDS_STATUS_ABORTED`, подпись можно исправить.
```
axelard q evm latest-batched-commands {chain name}
```

5. Сначала найдите адрес шлюза цепочки EVM. Используйте Metamask для отправки транзакции на этот адрес.
```
axelard q evm gateway-address {chain name}
```

Отправьте подписанную команду в цепочку EVM.
```
axelard q evm latest-batched-commands {chain name}
```
Скопируйте поле `execute_data` из запроса выше, вставьте значение в поле `data` EVM транзакции и отправьте её. Для этого можно использовать Metamask. Убедитесь, что Вы вручную увеличили «газовый лимит» транзакции перед ее отправкой. Используйте по крайней мере 2 000 000 газа, чтобы быть в безопасности.

6. Подтвердите передачу оператора.
Прежде чем инициировать подтверждение, убедитесь, что вы уже дождались достаточного количества подтверждений (в настоящее время 30) для транзакции. Как только передача оператора будет успешно подтверждена, система будет переключена на новый ключ. Обратите внимание, что подтверждение может быть запущено повторно, если Вы не дождались достаточного количества подтверждений.
```
axelard tx evm confirm-transfer-operatorship {chain name} {tx ID} {key ID} --from validator --gas auto --gas-adjustment 1.2
```
Дождитесь окончания голосования
Подтверждение и смена ключа успешно завершены, если следующий запрос дает ожидаемый идентификатор ключа.
```
axelard q evm address {chain name} --key-role secondary
```
