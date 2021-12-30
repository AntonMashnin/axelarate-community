---
id: btc-key-rotation
sidebar_position: 1
sidebar_label: Bitcoin Key Rotation
slug: /btc-key-rotation
---
# Ротация Первичного/Вторичного Ключа
Чтобы перейти на новый ключ, Вам нужно запустить транзакцию консолидации, отправив сумму изменения на главный/вторичный ключ, который отличается от текущего. Проверьте шаги [Транзакция Биткоин Консолидации](https://github.com/axelarnetwork/axelarate-community/blob/main/documentation/Admin/btc-consolidation-transaction.md), и убедитесь, что на шаге 1 используется другой идентификатор первичного/вторичного ключа.

Обратите внимание, что для версии axelar-core <= 0.7.x ручная ротация ключей должна запускаться после отправки транзакции биткоин консолидации.
```
axelard tx tss rotate bitcoin {key role, e.g. secondary or master} {a key ID} --from validator --gas auto --gas-adjustment 1.2
```
