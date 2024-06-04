#!/bin/bash

# Установите порог занятости диска (например, 95%)
DISK_THRESHOLD=95

# Получите процент занятости диска
DISK_USAGE=$(df -h | grep '/dev/sda1' | awk '{print $5}' | sed 's/%//g')

# Сравните текущую занятость с пороговым значением
if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
    # Отправьте предупреждение в rsyslog
    logger -p local0.warn "Внимание: занятость жесткого диска превысила $DISK_THRESHOLD%. Текущая занятость: $DISK_USAGE%"
fi
