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