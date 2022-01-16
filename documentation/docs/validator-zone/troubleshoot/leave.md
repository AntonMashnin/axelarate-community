# Перестать быть валидатором
-----------


!> :fire: TODO 2 metrics: consensus bonded/active and tss bonded/active.

1. Деактивируйте свою учетную запись валидатора.
```bash
axelard tx snapshot deactivate-proxy --from validator -y -b block
```

2. Дождитесь следующей ротации ключа, чтобы изменения вступили в силу. В этом релизе мы запускаем ротацию ключей примерно раз в день. Так что возвращайтесь через 24 часа и переходите к следующему шагу. Если вы по-прежнему получаете сообщение об ошибке через 24 часа, обратитесь к члену команды.

3. Отпустите застейканные монеты.
```bash
axelard tx staking unbond [axelarvaloper address] [amount]uaxl --from validator -y -b block
```
т.е:
```bash
axelard tx staking unbond "$(axelard keys show validator --bech val -a)" 100000000uaxl --from validator -y -b block
```
`amount` количество монет которое Вы хотите убрать со стейкинга. Вы можете изменить сумму.

Чтобы сохранить стабильность сети, застейканные монеты блокируются примерно на 1 день, начиная с запроса на "unstaking", прежде чем они будут разблокированы и возвращены на счет `валидатора`.
