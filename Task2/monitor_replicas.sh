#!/bin/bash
# Скрипт для мониторинга изменения количества реплик во время нагрузочного тестирования

echo "Мониторинг реплик Deployment scaletestapp"
echo "Нажмите Ctrl+C для остановки"
echo "=========================================="
echo ""

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    REPLICAS=$(kubectl get deployment scaletestapp -o jsonpath='{.status.replicas}')
    READY=$(kubectl get deployment scaletestapp -o jsonpath='{.status.readyReplicas}')
    MEMORY=$(kubectl get hpa scaletestapp -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null || echo "N/A")
    
    echo "[$TIMESTAMP] Реплики: $REPLICAS | Готово: $READY | Утилизация памяти: ${MEMORY}%"
    
    kubectl get pods -l app=scaletestapp -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,MEMORY:.status.containerStatuses[0].ready 2>/dev/null | tail -n +2
    
    echo "---"
    sleep 5
done

