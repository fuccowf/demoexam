#!/bin/bash

# Установите порог использования ОЗУ (например, 75%)
RAM_THRESHOLD=75

# Получите общее количество ОЗУ и доступное ОЗУ
TOTAL_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
AVAILABLE_RAM=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

# Вычислите текущее использование ОЗУ в процентах
CURRENT_USAGE=$(echo "scale=2; 100 - ($AVAILABLE_RAM/$TOTAL_RAM)*100" | bc)

# Сравните текущее использование с пороговым значением
if (( $(echo "$CURRENT_USAGE >= $RAM_THRESHOLD" | bc -l) )); then
    # Отправьте предупреждение в rsyslog
    logger -p local0.warn "Внимание: использование ОЗУ превысило $RAM_THRESHOLD%. Текущее использование: $CURRENT_USAGE%"
fi
