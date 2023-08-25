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
