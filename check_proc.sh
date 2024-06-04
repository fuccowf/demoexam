#!/bin/bash

# Установите порог CPU (например, 70%)
CPU_THRESHOLD=70

# Получите текущую загрузку CPU
CURRENT_LOAD=$(grep 'cpu' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')

# Сравните текущую загрузку с пороговым значением
if (( $(echo "$CURRENT_LOAD >= $CPU_THRESHOLD" | bc -l) )); then
    # Отправьте предупреждение в rsyslog
    logger -p local0.warn "Warning! Current processor load more than 70%"
fi
