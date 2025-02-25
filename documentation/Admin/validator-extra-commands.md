---
id: validator-commands
sidebar_position: 4
sidebar_label: Дополнительные команды валидатора
slug: /validator-extra-commands
---
# Дополнительные команды валидатора
Полезные команды для запроса внутреннего состояния сети Axelar для валидаторов.

## Отказ от ответственности
:::предупреждение Axelar Network находится в стадии разработки. Ни в коем случае нельзя передавать какие-либо реальные активы с помощью Axelar. Используйте только те токены тестовой сети, которые Вы не боитесь потерять. Axelar не несет ответственности за потерянные активы, или их заморозку или за токены которые не подлежат восстановлению в любом состоянии. Если Вы обнаружите проблему,пожалуйста, сообщите о ней используя данный репозиторий, следуя шаблону. 
:::

## Предварительные требования
- Выполните все шаги из этого руководства [Установка при помощи Docker(a)](/setup-docker) или [Установка из исходного кода](/setup-binaries)
- Попытка или завершение [Упражнение 3](/exercises/e3) чтобы присоединиться к сети в качестве валидатора и иметь общее представление о рабочем процессе

## Команды
В этом документе перечислены дополнительные команды, предоставляющие интересующую информацию для узлов валидатора. Команды отображают состояние валидаторов в сети и могут быть полезны для устранения неполадок.

При работе вне докера вам нужно будет указать домашний каталог, используя флаг `--home`. Особенно во время обучения.

### Запрос Вашего адреса Валидатора
```bash
axelard keys show validator --bech val -a
```

Возвращает адрес валидатора Вашего узла. Адрес валидатора начинается с `axelarvaloper` и используется во многих командах, связанных с валидатором.


### Запрос общих ключей Валидатора
```bash
axelard q tss key-shares-by-validator [validator address]
```
т.е)

```bash
axelard q tss key-shares-by-validator "$(axelard keys show validator --bech val -a)"
```

Возвращает информацию о списке пороговых ключей сети Axelar, которые в настоящее время принадлежат валидатору. Валидатор не должен владеть какими-либо активными общими ключами, когда он пытается выполнить unbound и перестать быть валидатором.


### Запрос Дерегистрации Валидаторов
```bash
axelard q tss deactivated-operators
```

Возвращает список валидаторов, регистрация которых в настоящее время отменена. Полезно для подтверждения успешного выполнения команды для отмены регистрации. Отмененные регистрации валидаторов не будут участвовать в будущих событиях генерации ключей и не будут владеть долями будущих ключей, что позволит им отвязаться позже.


### Снимок запроса
```bash
axelard q snapshot info [snapshot counter]
```
т.е)

```bash
axelard q snapshot info latest
```
```bash
axelard q snapshot info 2
```

Возвращает информацию о моментальном снимке с учетом номера счетчика моментальных снимков. Моментальный снимок делается во время каждого события генерации ключей, чтобы зафиксировать состояние сетевых валидаторов и количество долей ключа, которые будет удерживать каждый валидатор. Ключевое слово `latest` извлекает снимок самого последнего кейгена.


### Запросить информацию о всех валидаторов
```bash
axelard q snapshot validators
```

Возвращает информацию о состоянии всех валидаторов в сети.
