# /home/.axelar_testnet каталог пропущен

## Проблема
После запуска `join-testnet.sh`, `/home/.axelar_testnet` каталог пропущен. (Или содержимое папки устарело и не реагирует на изменения)

## Причина
`join-testnet.sh` был запущен с помощью sudo и `.axelar_testnet` папка была помещена в домашний каталог корневого профиля пользователя

## Решение
Запустите `join-testnet.sh` с флаго `--root` чтобы задать `.axelar_testnet` директорию.


