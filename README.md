# Mikrotik Telegram Notification

Glory to Ukraine! Слава Україні!

If you, like me, had problems with turning off the electricity. You left home to work in a cafe, and then called your neighbor every half hour and asked stupid questions about electricity. There is a solution to the problem if you have a Mikrotik router and 15 minutes of free time.

Instructions for creating notifications when the router is turned off by script and scheduler:

1) Create TG Bot.
You need to find BotFather (bot). Than give him the command:
```
 /newbot.
Bot_Name
Unique_name_bot
```  
p.s. Unique_name_bot - must be '_bot' in the end of the name.
After you create bot - BotFather give you 'token to access the HTTP API: 0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A'
Where 0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A is your token. You must safe it.

2) Save Telegram Chat ID.
Open your browser (or Postman) and isert link
```
https://api.telegram.org/bot0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A/getUpdates
```
where 0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A is your token to access the HTTP API.
Response is like:
```
 {"ok":true,"result":[{"update_id":000000000,
"channel_post":{"message_id":65,"sender_chat":{"id":-0000000000000,... 
```
Where -0000000000000 (sender_chat.id) - is your chat id. You must safe it.

p.s. 
if you have a problems with this endpoint - you can use telegram bot 'Get My ID'. 
You can send message for yourself by endpoint sendMessage
```
https://api.telegram.org/bot0000000000:AAAAaAAaAaaaAaa00000A00KT8AAaA0000A/sendMessage?chat_id=yourself_chat_id&text="Hello world"&parse_mode=html

```
When you have token to access the HTTP API and Chat ID, you can go to the next step.

3) Mikrotik
Connect by winbox to your router.
3.1) Change Identity
in winbox [System] -> [Identity] or by command
```
/system identity set name="MikroTik_Notification"
```
3.2) Create script
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

3.3) Add Scheduler
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

And thats all. You Can check this script on your microtik. Have a nice "notifications" :)

