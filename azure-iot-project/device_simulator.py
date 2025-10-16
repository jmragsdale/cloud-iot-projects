#!/usr/bin/env python3
"""
Azure IoT Device Simulator
Simulates temperature and humidity sensor data
"""

import asyncio
import json
import random
from datetime import datetime
from azure.iot.device.aio import IoTHubDeviceClient
from azure.iot.device import Message
import argparse

class AzureIoTDeviceSimulator:
    def __init__(self, connection_string, device_id):
        self.connection_string = connection_string
        self.device_id = device_id
        self.client = None
        
    async def connect(self):
        """Connect to Azure IoT Hub"""
        print(f"Connecting device '{self.device_id}' to Azure IoT Hub...")
        self.client = IoTHubDeviceClient.create_from_connection_string(
            self.connection_string
        )
        await self.client.connect()
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
            'deviceId': self.device_id,
            'temperature': round(temperature, 2),
            'humidity': round(humidity, 2),
            'timestamp': int(datetime.now().timestamp())
        }
    
    async def send_telemetry(self, interval=5, count=None):
        """Send telemetry data at specified interval"""
        print(f"\nSending telemetry data...")
        print("Press Ctrl+C to stop\n")
        
        messages_sent = 0
        try:
            while True:
                if count is not None and messages_sent >= count:
                    break
                    
                data = self.generate_sensor_data()
                message_json = json.dumps(data)
                message = Message(message_json)
                
                # Add custom properties
                message.content_type = "application/json"
                message.content_encoding = "utf-8"
                message.custom_properties["temperatureAlert"] = "true" if data['temperature'] > 30 else "false"
                
                await self.client.send_message(message)
                
                print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Sent: {message_json}")
                messages_sent += 1
                
                await asyncio.sleep(interval)
                
        except KeyboardInterrupt:
            print("\nStopping...")
        except Exception as e:
            print(f"Error: {e}")
        
        print(f"\nTotal messages sent: {messages_sent}")
    
    async def disconnect(self):
        """Disconnect from Azure IoT Hub"""
        if self.client:
            print("Disconnecting...")
            await self.client.disconnect()
            print("Disconnected!")

async def main():
    parser = argparse.ArgumentParser(description='Azure IoT Device Simulator')
    parser.add_argument('--connection-string', required=True, help='Device connection string')
    parser.add_argument('--device-id', default='temperature-sensor-001', help='Device ID')
    parser.add_argument('--interval', type=int, default=5, help='Send interval in seconds')
    parser.add_argument('--count', type=int, help='Number of messages to send (default: unlimited)')
    
    args = parser.parse_args()
    
    simulator = AzureIoTDeviceSimulator(
        connection_string=args.connection_string,
        device_id=args.device_id
    )
    
    try:
        await simulator.connect()
        await simulator.send_telemetry(interval=args.interval, count=args.count)
    finally:
        await simulator.disconnect()

if __name__ == '__main__':
    asyncio.run(main())
