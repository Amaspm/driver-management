package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/segmentio/kafka-go"
)

type DriverStatus struct {
	DriverID string `json:"driver_id"`
	Kota     string `json:"kota"`
	Status   string `json:"status"`
}

type OrderRequest struct {
	OrderID string `json:"order_id"`
	Pickup  string `json:"pickup"`
	Tujuan  string `json:"tujuan"`
	Ongkos  int    `json:"ongkos"`
	Kota    string `json:"kota"`
}

type OrderResponse struct {
	DriverID string `json:"driver_id"`
	OrderID  string `json:"order_id"`
	Action   string `json:"action"`
}

var (
	upgrader = websocket.Upgrader{
		CheckOrigin: func(r *http.Request) bool { return true },
	}
	drivers     = make(map[string]*websocket.Conn)
	driversLock = sync.RWMutex{}
	onlineDrivers = make(map[string]DriverStatus)
)

var kafkaBroker string

func main() {
	kafkaBroker = os.Getenv("KAFKA_BROKER")
	if kafkaBroker == "" {
		kafkaBroker = "kafka:9092"
	}
	
	log.Printf("Using Kafka broker: %s", kafkaBroker)

	// Start Kafka consumers
	go consumeDriverStatus(kafkaBroker)
	go consumeOrderRequests(kafkaBroker)
	go consumeOrderResponses(kafkaBroker)

	// WebSocket endpoint for drivers
	http.HandleFunc("/ws", handleWebSocket)
	
	// HTTP endpoints
	http.HandleFunc("/driver/status", handleDriverStatus)
	http.HandleFunc("/drivers/online", handleOnlineDrivers)
	http.HandleFunc("/order/request", handleOrderRequest)
	http.HandleFunc("/order/response", handleOrderResponse)

	log.Println("Driver service starting on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}
	defer conn.Close()

	driverID := r.URL.Query().Get("driver_id")
	if driverID == "" {
		log.Println("Missing driver_id parameter")
		return
	}

	driversLock.Lock()
	drivers[driverID] = conn
	driversLock.Unlock()

	log.Printf("Driver %s connected", driverID)

	// Keep connection alive
	for {
		_, _, err := conn.ReadMessage()
		if err != nil {
			log.Printf("Driver %s disconnected: %v", driverID, err)
			driversLock.Lock()
			delete(drivers, driverID)
			driversLock.Unlock()
			break
		}
	}
}

func handleDriverStatus(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var status DriverStatus
	if err := json.NewDecoder(r.Body).Decode(&status); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	log.Printf("Driver status update: %+v", status)

	// Update local driver status
	if status.Status == "online" {
		onlineDrivers[status.DriverID] = status
		log.Printf("Driver %s is now online in %s", status.DriverID, status.Kota)
	} else {
		delete(onlineDrivers, status.DriverID)
		log.Printf("Driver %s is now offline", status.DriverID)
	}

	// Also publish to Kafka (fallback)
	publishDriverStatus(status)
	w.WriteHeader(http.StatusOK)
}

func handleOrderRequest(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var order OrderRequest
	if err := json.NewDecoder(r.Body).Decode(&order); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	log.Printf("Received order request: %+v", order)

	// Send directly to online drivers in the same city
	sentCount := 0
	for driverID, driverStatus := range onlineDrivers {
		if driverStatus.Kota == order.Kota {
			log.Printf("Sending order to driver %s in city %s", driverID, order.Kota)
			sendOrderToDriver(driverID, order)
			sentCount++
		}
	}

	log.Printf("Order sent to %d drivers", sentCount)

	// Also try to publish to Kafka (fallback)
	publishOrderRequest(order)
	w.WriteHeader(http.StatusOK)
}

func publishDriverStatus(status DriverStatus) {
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers: []string{kafkaBroker},
		Topic:   "driver_status",
	})
	defer writer.Close()

	message, _ := json.Marshal(status)
	writer.WriteMessages(context.Background(), kafka.Message{
		Value: message,
	})
}

func publishOrderRequest(order OrderRequest) {
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers: []string{kafkaBroker},
		Topic:   "order_request",
	})
	defer writer.Close()

	message, _ := json.Marshal(order)
	writer.WriteMessages(context.Background(), kafka.Message{
		Value: message,
	})
}

func consumeDriverStatus(broker string) {
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: []string{broker},
		Topic:   "driver_status",
		GroupID: "driver-service",
	})
	defer reader.Close()

	for {
		msg, err := reader.ReadMessage(context.Background())
		if err != nil {
			log.Printf("Error reading driver status: %v", err)
			continue
		}

		var status DriverStatus
		if err := json.Unmarshal(msg.Value, &status); err != nil {
			log.Printf("Error unmarshaling driver status: %v", err)
			continue
		}

		if status.Status == "online" {
			onlineDrivers[status.DriverID] = status
		} else {
			delete(onlineDrivers, status.DriverID)
		}

		log.Printf("Driver %s is now %s", status.DriverID, status.Status)
	}
}

func consumeOrderRequests(broker string) {
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: []string{broker},
		Topic:   "order_request",
		GroupID: "driver-service",
	})
	defer reader.Close()

	for {
		msg, err := reader.ReadMessage(context.Background())
		if err != nil {
			log.Printf("Error reading order request: %v", err)
			continue
		}

		var order OrderRequest
		if err := json.Unmarshal(msg.Value, &order); err != nil {
			log.Printf("Error unmarshaling order request: %v", err)
			continue
		}

		// Find online drivers in the same city
		for driverID, driverStatus := range onlineDrivers {
			if driverStatus.Kota == order.Kota {
				sendOrderToDriver(driverID, order)
			}
		}
	}
}

func consumeOrderResponses(broker string) {
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: []string{broker},
		Topic:   "order_response",
		GroupID: "driver-service",
	})
	defer reader.Close()

	for {
		msg, err := reader.ReadMessage(context.Background())
		if err != nil {
			log.Printf("Error reading order response: %v", err)
			continue
		}

		var response OrderResponse
		if err := json.Unmarshal(msg.Value, &response); err != nil {
			log.Printf("Error unmarshaling order response: %v", err)
			continue
		}

		log.Printf("Driver %s %s order %s", response.DriverID, response.Action, response.OrderID)
		// TODO: Update Django backend with order status
	}
}

func handleOnlineDrivers(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"online_drivers": onlineDrivers,
		"connected_drivers": getConnectedDrivers(),
	})
}

func getConnectedDrivers() []string {
	driversLock.RLock()
	defer driversLock.RUnlock()
	
	var connected []string
	for driverID := range drivers {
		connected = append(connected, driverID)
	}
	return connected
}

func handleOrderResponse(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var response OrderResponse
	if err := json.NewDecoder(r.Body).Decode(&response); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	// Publish to Kafka
	publishOrderResponse(response)
	w.WriteHeader(http.StatusOK)
}

func publishOrderResponse(response OrderResponse) {
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers: []string{kafkaBroker},
		Topic:   "order_response",
	})
	defer writer.Close()

	message, _ := json.Marshal(response)
	writer.WriteMessages(context.Background(), kafka.Message{
		Value: message,
	})
}

func sendOrderToDriver(driverID string, order OrderRequest) {
	driversLock.RLock()
	conn, exists := drivers[driverID]
	driversLock.RUnlock()

	if !exists {
		log.Printf("Driver %s not connected", driverID)
		return
	}

	message, _ := json.Marshal(order)
	log.Printf("Sending message to driver %s: %s", driverID, string(message))
	if err := conn.WriteMessage(websocket.TextMessage, message); err != nil {
		log.Printf("Error sending order to driver %s: %v", driverID, err)
		driversLock.Lock()
		delete(drivers, driverID)
		driversLock.Unlock()
	} else {
		log.Printf("Successfully sent order to driver %s", driverID)
	}
}