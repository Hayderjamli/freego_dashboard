"""WebSocket-enabled IoT streaming server for the FreeGo dashboard.

Run this script on the Raspberry Pi that hosts the camera and DHT22 sensor.
"""
import asyncio
import threading
import time
import json
import base64

import cv2
import numpy as np
import websockets
from flask import Flask
from picamera2 import Picamera2
import board
import adafruit_dht

app = Flask(__name__, static_folder=".", static_url_path="")

picam2 = Picamera2()
picam2.configure(picam2.create_preview_configuration(main={"size": (640, 480)}))
picam2.set_controls({"AwbEnable": True})
# camera_active is kept for backward compatibility with commands that start/stop the camera
camera_active = False

dht = adafruit_dht.DHT22(board.D4)
sensor_data: list[dict[str, float | str]] = []


@app.route("/")
def index() -> str:
    return app.send_static_file("index.html")


def apply_color_correction(frame: np.ndarray) -> np.ndarray:
    """Simple color space conversion - RGB to BGR."""
    # Picamera2 captures in RGB format, convert to BGR for proper colors
    frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
    return frame_bgr


async def handler(websocket: websockets.WebSocketServerProtocol) -> None:
    global camera_active
    print("📡 Client connected from:", websocket.remote_address)

    async def send_sensor_data(task_cancel_event: asyncio.Event) -> None:
        # Periodically read DHT sensor and send JSON with keys matching the Flutter client
        while not task_cancel_event.is_set():
            try:
                temp = dht.temperature
                hum = dht.humidity
                if temp is not None and hum is not None:
                    ts = time.strftime("%H:%M:%S")
                    sensor_data.append({"t": ts, "temp": temp, "hum": hum})
                    if len(sensor_data) > 100:
                        sensor_data.pop(0)
                    # Use explicit keys expected by clients: temperature/humidity
                    msg = json.dumps({"type": "sensor", "temperature": temp, "humidity": hum, "time": ts})
                    await websocket.send(msg)
                    print(f"✅ Sent sensor data: {temp}°C, {hum}%")
            except Exception as e:  # pragma: no cover - sensor errors only visible on hardware
                print("❌ Sensor read error:", e)
            try:
                await asyncio.wait_for(asyncio.sleep(3), timeout=5)
            except asyncio.CancelledError:
                break

    # per-connection cancellation/event for background tasks
    cancel_event = asyncio.Event()
    tasks: list[asyncio.Task[None]] = []
    try:
        # start sensor task for this connection
        tasks.append(asyncio.create_task(send_sensor_data(cancel_event)))

        # streaming task will be created on demand
        stream_task: asyncio.Task[None] | None = None

        async for message in websocket:
            print(f"📨 Received: {message}")
            # Support simple command formats and a lightweight START_STREAM:fps
            if isinstance(message, str) and message.startswith("START_STREAM"):
                # message can be 'START_STREAM' or 'START_STREAM:2' (fps)
                parts = message.split(":")
                fps = 2
                if len(parts) > 1:
                    try:
                        fps = max(1, int(parts[1]))
                    except Exception:
                        fps = 2

                async def streamer() -> None:
                    global camera_active
                    camera_active = True
                    try:
                        picam2.start()
                    except Exception:
                        pass
                    interval = 1.0 / fps
                    print(f"🎞️ Starting stream at {fps} FPS (interval {interval}s)")
                    while not cancel_event.is_set():
                        try:
                            frame = picam2.capture_array()
                            frame_corrected = apply_color_correction(frame)
                            _, buffer = cv2.imencode(".jpg", frame_corrected)
                            img_str = base64.b64encode(buffer).decode("utf-8")
                            await websocket.send(json.dumps({"type": "frame", "data": img_str}))
                        except Exception as e:  # pragma: no cover - runtime/hardware errors only
                            print("❌ Stream frame error:", e)
                        try:
                            await asyncio.wait_for(asyncio.sleep(interval), timeout=interval + 1)
                        except asyncio.CancelledError:
                            break

                # cancel existing stream task if present
                if stream_task is not None and not stream_task.done():
                    stream_task.cancel()
                stream_task = asyncio.create_task(streamer())
                tasks.append(stream_task)

            elif isinstance(message, str) and message.startswith("STOP_STREAM"):
                # stop streaming
                if stream_task is not None:
                    stream_task.cancel()
                    stream_task = None
                    print("🛑 Stream stopped")

            elif message == "START_CAMERA":
                camera_active = True
                try:
                    picam2.start()
                except Exception:
                    pass
                print("🎥 Camera started")
            elif message == "STOP_CAMERA":
                camera_active = False
                try:
                    picam2.stop()
                except Exception:
                    pass
                print("🎥 Camera stopped")
            elif message == "GET_FRAME":
                # send one frame on demand (start camera temporarily if necessary)
                try:
                    if not camera_active:
                        try:
                            picam2.start()
                        except Exception:
                            pass
                    frame = picam2.capture_array()
                    # Apply color correction
                    frame_corrected = apply_color_correction(frame)
                    _, buffer = cv2.imencode(".jpg", frame_corrected)
                    img_str = base64.b64encode(buffer).decode("utf-8")
                    await websocket.send(json.dumps({"type": "frame", "data": img_str}))
                except Exception as e:  # pragma: no cover - runtime/hardware errors only
                    print("❌ Frame error:", e)
    except websockets.exceptions.ConnectionClosed:
        print("📡 Client disconnected")
    finally:
        # signal background tasks to stop and cancel them
        try:
            cancel_event.set()
        except Exception:
            pass
        for t in tasks:
            try:
                t.cancel()
            except Exception:
                pass
        # stop camera if it was only started for this connection
        # (do not force-stop if other logic needs it)
        try:
            if camera_active:
                # keep camera state as-is; if desired, uncomment next line to stop
                # picam2.stop()
                pass
        except Exception:
            pass


async def ws_server() -> None:
    try:
        async with websockets.serve(handler, "0.0.0.0", 8000):
            print("✅ WebSocket server running on ws://0.0.0.0:8000")
            await asyncio.Future()
    except Exception as e:  # pragma: no cover - runtime errors only
        print("❌ WebSocket server error:", e)


def start_flask() -> None:
    print("✅ Flask server running on http://0.0.0.0:5000")
    app.run(host="0.0.0.0", port=5000, debug=False, threaded=True)


if __name__ == "__main__":
    print("🚀 Starting Herotopia server...")
    threading.Thread(target=start_flask, daemon=True).start()
    asyncio.run(ws_server())
