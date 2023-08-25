# Mikrotik Telegram Notification 🇺🇦

[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=600&size=30&duration=4000&pause=1500&color=805FA6&width=435&lines=Glory+to+Ukraine!;%D0%A1%D0%BB%D0%B0%D0%B2%D0%B0+%D0%A3%D0%BA%D1%80%D0%B0%D1%97%D0%BD%D1%96!)](https://git.io/typing-svg) 

![](https://komarev.com/ghpvc/?username=AngelOfDeath-UA)

If you, like me, had problems with turning off the electricity. You left home to work in a cafe, and then called your neighbor every half hour and asked stupid questions about electricity. There is a solution to the problem if you have a Mikrotik router and 15 minutes of free time.

My script is more productive - because when mikrotik start, scrip automatic launches one loop. The loop starts a script that will be executed automatically until there is a stable internet (check pockets of Google DNS) and it will not be possible to send a message to Telegram. After script send the message, loop will be end.

 So, the script is started once, (not every 5-10 minutes during the all life of the router working) like in the enother scripts in the internet.

### Tested on: MikroTik hAP Lite (RB941-2nD) with RouterOS: 6.49.8

Instructions for creating notifications when the router is turned off by the script and scheduler:

## 1) Create TG Bot.

You need to find BotFather (bot). Than give him the command:

```
/newbot
```
BotFather ask you 2 questions Name of the bot (example: MikroTik Notification) and a unique username for your bot. It must end in `bot`. Like this, for example: TetrisBot or tetris_bot.

After you create bot - BotFather give you 'token to access the HTTP API: 0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A'

Where 0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A is your token. You must safe it.

## 2) Save Telegram Chat ID.

Open your browser (or Postman) and insert link:

```
https://api.telegram.org/bot0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A/getUpdates
```
Where 0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A is your token to access the HTTP API.

Response is like:
```
 {"ok":true,"result":[{"update_id":000000000,
"channel_post":{"message_id":65,"sender_chat":{"id":-0000000000000,... 
```
Where -0000000000000 (sender_chat.id) - is your chat id. You must safe it.

P.s. 

If you have a problems with this endpoint - you can use enother telegram bot 'Get My ID'. 

You can send message for yourself by endpoint /sendMessage

```
https://api.telegram.org/bot0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A/sendMessage?chat_id=yourself_chat_id&text="Hello world"&parse_mode=html

```

When you have token to access the HTTP API and Chat ID, you can go to the next step.

## 3) Mikrotik
   
Connect by winbox to your router.

### 3.1) Change Identity

in winbox [System] -> [Identity] or by command
```
/system identity set name="MikroTik_Notification"
```
### 3.2) Create script

in winbox [System] -> [Scripts] -> [+] -> [Name: CheckPowerOn] -> [Policy: read, write, policy, test, sensitive]

Source:
```
# Func: Telegram send message
:local TGSendMessage do={
    :local tgUrl "https://api.telegram.org/bot$Token/sendMessage?chat_id=$ChatID&text=$Text&parse_mode=html";
    /tool fetch http-method=get url=$tgUrl keep-result=no;
}

# Constants
:global RebootStatus;
:local InternetStatus;
:local TelegramBotToken "0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A";
:local TelegramChatID "-0000000000000";
:local DeviceName [/system identity get name];

:local TelegramMessageText "\F0\9F\9F\A2 <b>$DeviceName:</b> start after Power Off. \E2\9A\A1 Electricity is ON!";

# Program

:if ([ping count=4 8.8.8.8] = 4) do={
    :set InternetStatus true
} else={
    :set InternetStatus false
}

:if ($InternetStatus) do={
    $TGSendMessage Token=$TelegramBotToken ChatID=$TelegramChatID Text=$TelegramMessageText;
    :set RebootStatus true;
    :log info "Script CheckPowerOn successful send Telegram message."
} else={
    :log error "No internet connection. Can't send Telegram message."
}

```

P.S. insert into TelegramBotToken and TelegramChatID - your values.

### 3.3) Add Scheduler

In winbox [System] -> [Schedule] -> [+] -> [Name: CheckPowerOn script] - > [Start Time: startup, Interval: 00:00:00] -> [Policy: read, write, policy, test, sensitive]

On Event:
```
:log info "Start CheckPowerOn script"

:global RebootStatus false;

:while ($RebootStatus !=  true) do={
    :delay 10000ms;
    :log info "Run CheckPowerOn Script."
    /system script run CheckPowerOn;
    :if ($RebootStatus =  true) do={
        :log info "Mikrotik have stabel internet connection and send Telegram message. Exit script.";
        :return;
    }
}
```

And that's all. You Can check this script on your Microtik. 

Have a nice "notifications"! :)

