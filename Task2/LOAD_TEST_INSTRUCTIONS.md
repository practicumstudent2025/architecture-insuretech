# Инструкции по нагрузочному тестированию и проверке HPA

## Предварительные требования

1. Убедитесь, что Locust установлен:
   ```bash
   pip install locust
   ```

2. Убедитесь, что все компоненты развернуты:
   ```bash
   kubectl get deployment scaletestapp
   kubectl get service scaletestapp
   kubectl get hpa scaletestapp
   ```

## Шаг 1: Запуск port-forward для доступа к сервису

В отдельном терминале запустите port-forward:

```bash
kubectl port-forward service/scaletestapp 8080:80
```

Оставьте этот терминал открытым.

## Шаг 2: Запуск Locust

В директории Task2 выполните:

```bash
cd Task2
locust --host=http://localhost:8080
```

Locust запустится на http://localhost:8089

## Шаг 3: Настройка теста в веб-интерфейсе Locust

1. Откройте браузер и перейдите на http://localhost:8089
2. Установите параметры:
   - **Number of users**: 50-100 (для генерации достаточной нагрузки)
   - **Spawn rate**: 5-10 (пользователей в секунду)
3. Нажмите "Start swarming"

## Шаг 4: Мониторинг реплик

В отдельном терминале запустите скрипт мониторинга:

```bash
chmod +x Task2/monitor_replicas.sh
./Task2/monitor_replicas.sh
```

Или вручную отслеживайте изменения:

```bash
watch -n 2 'kubectl get hpa scaletestapp && echo "" && kubectl get pods -l app=scaletestapp'
```

## Шаг 5: Запуск Kubernetes Dashboard

В отдельном терминале:

```bash
minikube dashboard
```

Dashboard откроется в браузере. Перейдите в раздел:
- **Workloads** → **Deployments** → **scaletestapp**
- **Workloads** → **Horizontal Pod Autoscalers** → **scaletestapp**

## Шаг 6: Сбор результатов

### Проверка текущего состояния HPA:

```bash
kubectl get hpa scaletestapp -o yaml > Task2/hpa_status.yaml
```

### Проверка истории масштабирования:

```bash
kubectl describe hpa scaletestapp > Task2/hpa_describe.txt
```

### Проверка метрик подов:

```bash
kubectl top pods -l app=scaletestapp > Task2/pods_metrics.txt
```

### Проверка событий:

```bash
kubectl get events --sort-by='.lastTimestamp' | grep scaletestapp > Task2/events.txt
```

## Ожидаемое поведение

1. При увеличении нагрузки утилизация памяти подов должна расти
2. Когда утилизация памяти превысит 80%, HPA должен начать создавать новые реплики
3. Количество реплик должно увеличиваться до максимума 10 (если нагрузка достаточна)
4. После снижения нагрузки реплики должны постепенно уменьшаться (с задержкой 300 секунд)

## Проверка результатов

После завершения теста проверьте:

```bash
# Финальное состояние HPA
kubectl get hpa scaletestapp

# История масштабирования
kubectl describe hpa scaletestapp | grep -A 20 "Events:"

# Текущее количество реплик
kubectl get deployment scaletestapp
```

