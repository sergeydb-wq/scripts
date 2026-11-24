# wannaclient

wannacry — Roblox client: визуалы, ESP, движение (Strafe/Fly), 24 косметики с превью, Community (Global Chat, юзеры скрипта на сервере, админ-панель), конфиги.

## Запуск

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/sergeydb-wq/scripts/wannaclient/wannacry.lua"))()
```

Меню: Insert (меняется в Settings) или кнопка-логотип слева сверху.

## Скрипты под игры

Тот же wannacry + вкладка **«Игра»** с подвкладками игровых функций. Значения функций сохраняются в конфиги wannacry.

**WannaBloc и WannaCarry работают по ключу** (wannacry Visuals — бесплатно). При запуске появится окно ввода ключа; ключ выдаёт Telegram-бот WannaCry и сохраняется на ПК (`workspace/wannacry/keys.json`). Сам код скриптов отдаёт сервер ключей только с действующим ключом.

| Скрипт | Игра | Подвкладки |
|---|---|---|
| WannaBloc | BlockCraft | Бой, Движение, Фарм, Визуалы |
| WannaCarry | Carry People 3 | Бой, Движение, Игрок, Визуалы, Разное, История, Сервер (без ключа) |

```lua
-- WannaBloc (BlockCraft)
loadstring(game:HttpGet("https://raw.githubusercontent.com/sergeydb-wq/scripts/wannaclient/WannaBloc.lua"))()

-- WannaCarry (Carry People 3)
loadstring(game:HttpGet("https://raw.githubusercontent.com/sergeydb-wq/scripts/wannaclient/WannaCarry.lua"))()
```
