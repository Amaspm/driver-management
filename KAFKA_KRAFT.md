# Kafka KRaft Mode (Tanpa Zookeeper)

## Perubahan yang Dilakukan

✅ **Menghapus Zookeeper** - Tidak diperlukan lagi
✅ **Menggunakan Kafka 7.4.0** - Versi terbaru dengan KRaft
✅ **KRaft Mode** - Kafka mengelola metadata sendiri

## Keuntungan KRaft Mode

- **Lebih Sederhana**: Hanya 1 service (Kafka) vs 2 service (Kafka + Zookeeper)
- **Performa Lebih Baik**: Metadata handling lebih efisien
- **Resource Lebih Hemat**: Mengurangi memory dan CPU usage
- **Startup Lebih Cepat**: Tidak perlu wait Zookeeper ready

## Konfigurasi KRaft

```yaml
KAFKA_PROCESS_ROLES: broker,controller  # Kafka sebagai broker dan controller
KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:29093  # Self-managed quorum
KAFKA_LOG_DIRS: /tmp/kraft-combined-logs  # Combined log directory
CLUSTER_ID: MkU3OEVBNTcwNTJENDM2Qk  # Unique cluster ID
```

## Cara Menjalankan

```bash
# Start services (tanpa Zookeeper)
docker-compose up -d

# Setup topics
./setup_kafka.sh

# Check Kafka status
docker-compose exec kafka kafka-topics --list --bootstrap-server kafka:9092
```

## Monitoring

```bash
# List topics
docker-compose exec kafka kafka-topics --list --bootstrap-server kafka:9092

# Describe topic
docker-compose exec kafka kafka-topics --describe --topic driver_status --bootstrap-server kafka:9092

# Consumer test
docker-compose exec kafka kafka-console-consumer --topic driver_status --bootstrap-server kafka:9092 --from-beginning
```

Setup sekarang lebih sederhana dan modern!