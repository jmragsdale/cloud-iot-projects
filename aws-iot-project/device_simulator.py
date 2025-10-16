#!/usr/bin/env python3
"""
AWS IoT Device Simulator
Simulates temperature and humidity sensor data
"""

import json
import time
import random
from datetime import datetime
from awscrt import io, mqtt
from awsiot import mqtt_connection_builder
import sys
import argparse

class IoTDeviceSimulator:
    def __init__(self, endpoint, cert_path, key_path, root_ca_path, client_id, topic):
        self.endpoint = endpoint
        self.cert_path = cert_path
        self.key_path = key_path
        self.root_ca_path = root_ca_path
        self.client_id = client_id
        self.topic = topic
        self.connection = None
        
    def connect(self):
        """Connect to AWS IoT Core"""
        print(f"Connecting to {self.endpoint} with client ID '{self.client_id}'...")
        
        # Create MQTT connection
        event_loop_group = io.EventLoopGroup(1)
        host_resolver = io.DefaultHostResolver(event_loop_group)
        client_bootstrap = io.ClientBootstrap(event_loop_group, host_resolver)
        
        self.connection = mqtt_connection_builder.mtls_from_path(
            endpoint=self.endpoint,
            cert_filepath=self.cert_path,
            pri_key_filepath=self.key_path,
            client_bootstrap=client_bootstrap,
            ca_filepath=self.root_ca_path,
            client_id=self.client_id,
            clean_session=False,
            keep_alive_secs=30
        )
        
        connect_future = self.connection.connect()
        connect_future.result()
        print("Connected!")
        
    def generate_sensor_data(self):
        """Generate simulated temperature and humidity data"""
        # Base temperature with some variation
        base_temp = 25
        temperature = base_temp + random.uniform(-5, 15)
        
        # Humidity inversely correlated with temperature
        humidity = 70 - (temperature - base_temp) * 2 + random.uniform(-10, 10)
        humidity = max(30, min(90, humidity))  # Keep between 30-90%
        
        return {
            'deviceId': self.client_id,
            'temperature': round(temperature, 2),
            'humidity': round(humidity, 2),
            'timestamp': int(datetime.now().timestamp())
        }
    
    def publish_data(self, interval=5, count=None):
        """Publish sensor data at specified interval"""
        print(f"\nPublishing to topic '{self.topic}'...")
        print("Press Ctrl+C to stop\n")
        
        messages_sent = 0
        try:
            while True:
                if count is not None and messages_sent >= count:
                    break
                    
                data = self.generate_sensor_data()
                message = json.dumps(data)
                
                self.connection.publish(
                    topic=self.topic,
                    payload=message,
                    qos=mqtt.QoS.AT_LEAST_ONCE
                )
                
                print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Published: {message}")
                messages_sent += 1
                
                time.sleep(interval)
                
        except KeyboardInterrupt:
            print("\nStopping...")
        
        print(f"\nTotal messages sent: {messages_sent}")
    
    def disconnect(self):
        """Disconnect from AWS IoT Core"""
        if self.connection:
            print("Disconnecting...")
            disconnect_future = self.connection.disconnect()
            disconnect_future.result()
            print("Disconnected!")

def main():
    parser = argparse.ArgumentParser(description='AWS IoT Device Simulator')
    parser.add_argument('--endpoint', required=True, help='AWS IoT endpoint')
    parser.add_argument('--cert', required=True, help='Path to certificate file')
    parser.add_argument('--key', required=True, help='Path to private key file')
    parser.add_argument('--root-ca', required=True, help='Path to root CA file')
    parser.add_argument('--client-id', default='temp-sensor-001', help='MQTT client ID')
    parser.add_argument('--topic', default='iot/temperature', help='MQTT topic')
    parser.add_argument('--interval', type=int, default=5, help='Publish interval in seconds')
    parser.add_argument('--count', type=int, help='Number of messages to send (default: unlimited)')
    
    args = parser.parse_args()
    
    simulator = IoTDeviceSimulator(
        endpoint=args.endpoint,
        cert_path=args.cert,
        key_path=args.key,
        root_ca_path=args.root_ca,
        client_id=args.client_id,
        topic=args.topic
    )
    
    try:
        simulator.connect()
        simulator.publish_data(interval=args.interval, count=args.count)
    finally:
        simulator.disconnect()

if __name__ == '__main__':
    main()
