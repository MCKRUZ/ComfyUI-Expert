# ComfyUI Instance Management

Robust management of ComfyUI instances with health monitoring, auto-restart, and multi-instance orchestration.

---

## Health Monitoring

### Endpoint Checks

```python
import requests
import time

def check_comfyui_health(url="http://127.0.0.1:8188"):
    """Check if ComfyUI is responsive"""
    endpoints = {
        "system_stats": f"{url}/system_stats",
        "queue": f"{url}/queue",
        "history": f"{url}/history",
        "prompt": f"{url}/prompt"
    }

    health = {}
    for name, endpoint in endpoints.items():
        try:
            response = requests.get(endpoint, timeout=5)
            health[name] = response.status_code == 200
        except:
            health[name] = False

    return all(health.values()), health
```

### Queue Monitoring

```python
def monitor_queue(url="http://127.0.0.1:8188", interval=30):
    """Monitor queue for stalls"""
    previous_queue_size = None
    stall_count = 0

    while True:
        try:
            response = requests.get(f"{url}/queue")
            data = response.json()

            current_queue = data.get("queue_running", [])
            queue_size = len(current_queue)

            # Check if queue is stalled
            if queue_size > 0 and queue_size == previous_queue_size:
                stall_count += 1
                if stall_count >= 10:  # 5 minutes at 30s intervals
                    return "STALLED"
            else:
                stall_count = 0

            previous_queue_size = queue_size
            time.sleep(interval)

        except Exception as e:
            return f"ERROR: {e}"
```

### VRAM Monitoring

```python
def check_vram_usage(threshold_gb=28):
    """Monitor VRAM usage (requires nvidia-smi)"""
    import subprocess

    try:
        result = subprocess.run(
            ['nvidia-smi', '--query-gpu=memory.used', '--format=csv,noheader,nounits'],
            capture_output=True,
            text=True
        )

        vram_used_mb = int(result.stdout.strip())
        vram_used_gb = vram_used_mb / 1024

        if vram_used_gb > threshold_gb:
            return "HIGH_VRAM", vram_used_gb

        return "OK", vram_used_gb

    except Exception as e:
        return "UNKNOWN", 0
```

---

## Auto-Restart Procedures

### Graceful Restart

```python
import subprocess
import psutil
import time

def restart_comfyui(
    comfyui_path="E:/ComfyUI-Easy-Install/ComfyUI",
    port=8188,
    python_path="python"
):
    """Gracefully restart ComfyUI instance"""

    print("[Restart] Saving queue state...")
    save_queue_state(port)

    print("[Restart] Finding ComfyUI process...")
    killed = kill_comfyui_process(port)

    if killed:
        print("[Restart] Process terminated")
    else:
        print("[Restart] No process found (may have crashed)")

    print("[Restart] Waiting for port release...")
    wait_for_port_release(port, timeout=30)

    print("[Restart] Starting ComfyUI...")
    start_comfyui(comfyui_path, port, python_path)

    print("[Restart] Waiting for API to respond...")
    wait_for_api_ready(port, timeout=120)

    print("[Restart] Restoring queue state...")
    restore_queue_state(port)

    print("[Restart] ✓ ComfyUI restarted successfully")
```

### Save/Restore Queue

```python
import json

def save_queue_state(port=8188):
    """Save pending queue items before restart"""
    url = f"http://127.0.0.1:{port}/queue"

    try:
        response = requests.get(url)
        data = response.json()

        with open(f"queue_backup_{port}.json", "w") as f:
            json.dump(data, f, indent=2)

        return True
    except:
        return False

def restore_queue_state(port=8188):
    """Restore queue after restart"""
    backup_file = f"queue_backup_{port}.json"

    if not os.path.exists(backup_file):
        return False

    with open(backup_file, "r") as f:
        data = json.load(f)

    # Re-submit pending items
    for item in data.get("queue_pending", []):
        # Extract workflow from queue item
        workflow = item[2]  # Workflow is 3rd element in queue tuple
        submit_workflow(workflow, port)

    os.remove(backup_file)
    return True
```

### Process Management

```python
def kill_comfyui_process(port=8188):
    """Find and kill ComfyUI process by port"""
    for proc in psutil.process_iter(['pid', 'name', 'connections']):
        try:
            for conn in proc.connections():
                if conn.laddr.port == port:
                    proc.terminate()
                    proc.wait(timeout=10)
                    return True
        except:
            continue

    return False

def wait_for_port_release(port, timeout=30):
    """Wait until port is no longer in use"""
    start = time.time()

    while time.time() - start < timeout:
        in_use = False
        for proc in psutil.process_iter(['connections']):
            try:
                for conn in proc.connections():
                    if conn.laddr.port == port:
                        in_use = True
                        break
            except:
                continue
            if in_use:
                break

        if not in_use:
            return True

        time.sleep(1)

    return False

def start_comfyui(comfyui_path, port=8188, python_path="python"):
    """Start ComfyUI process"""
    cmd = [
        python_path,
        "main.py",
        "--port", str(port),
        "--highvram",
        "--fp8_e4m3fn-unet"
    ]

    subprocess.Popen(
        cmd,
        cwd=comfyui_path,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )

def wait_for_api_ready(port, timeout=120):
    """Wait for ComfyUI API to become responsive"""
    start = time.time()
    url = f"http://127.0.0.1:{port}/queue"

    while time.time() - start < timeout:
        try:
            response = requests.get(url, timeout=5)
            if response.status_code == 200:
                return True
        except:
            pass

        time.sleep(2)

    return False
```

---

## Multi-Instance Management

### Instance Configuration

```python
INSTANCES = {
    "primary": {
        "port": 8188,
        "path": "E:/ComfyUI-Easy-Install/ComfyUI",
        "purpose": "I2V generation",
        "priority": 1
    },
    "secondary": {
        "port": 8189,
        "path": "E:/ComfyUI-Easy-Install/ComfyUI",
        "purpose": "upscaling/post-processing",
        "priority": 2
    },
    "backup": {
        "port": 8190,
        "path": "E:/ComfyUI-Easy-Install/ComfyUI",
        "purpose": "failover standby",
        "priority": 3
    }
}
```

### Load Balancer

```python
class ComfyUILoadBalancer:
    def __init__(self, instances):
        self.instances = instances
        self.round_robin_index = 0

    def get_healthiest_instance(self):
        """Return instance with lowest queue size"""
        queue_sizes = {}

        for name, config in self.instances.items():
            try:
                url = f"http://127.0.0.1:{config['port']}/queue"
                response = requests.get(url, timeout=5)
                data = response.json()
                queue_sizes[name] = len(data.get("queue_running", []))
            except:
                queue_sizes[name] = float('inf')  # Mark as unavailable

        return min(queue_sizes, key=queue_sizes.get)

    def get_next_round_robin(self):
        """Return next instance in round-robin"""
        instances_list = list(self.instances.keys())
        instance = instances_list[self.round_robin_index]
        self.round_robin_index = (self.round_robin_index + 1) % len(instances_list)
        return instance

    def submit_to_best_instance(self, workflow):
        """Submit workflow to best available instance"""
        instance_name = self.get_healthiest_instance()
        config = self.instances[instance_name]

        return submit_workflow(workflow, config['port'])
```

### Failover Handler

```python
def submit_with_failover(workflow, primary_port=8188, backup_ports=[8189, 8190]):
    """Try primary, fall back to backups if needed"""
    ports = [primary_port] + backup_ports

    for port in ports:
        try:
            result = submit_workflow(workflow, port)
            print(f"[Failover] Submitted to port {port}")
            return result
        except Exception as e:
            print(f"[Failover] Port {port} failed: {e}")
            continue

    raise Exception("All instances failed")
```

---

## Startup Scripts

### Windows (PowerShell)

```powershell
# start-comfyui-multi.ps1
# Start multiple ComfyUI instances

$instances = @(
    @{ Port = 8188; Purpose = "Primary I2V" },
    @{ Port = 8189; Purpose = "Upscaling" },
    @{ Port = 8190; Purpose = "Backup" }
)

$comfyuiPath = "E:\ComfyUI-Easy-Install\ComfyUI"

foreach ($instance in $instances) {
    $port = $instance.Port
    $purpose = $instance.Purpose

    Write-Host "Starting ComfyUI on port $port ($purpose)..."

    Start-Process python -ArgumentList @(
        "main.py",
        "--port", $port,
        "--highvram",
        "--fp8_e4m3fn-unet"
    ) -WorkingDirectory $comfyuiPath -WindowStyle Hidden

    Start-Sleep -Seconds 5
}

Write-Host "All instances started!"
Write-Host "Primary: http://localhost:8188"
Write-Host "Secondary: http://localhost:8189"
Write-Host "Backup: http://localhost:8190"
```

### Linux/Mac (Bash)

```bash
#!/bin/bash
# start-comfyui-multi.sh

COMFYUI_PATH="$HOME/ComfyUI"

start_instance() {
    local port=$1
    local purpose=$2

    echo "Starting ComfyUI on port $port ($purpose)..."

    cd "$COMFYUI_PATH"
    python main.py \
        --port $port \
        --highvram \
        --fp8_e4m3fn-unet \
        > "logs/comfyui_$port.log" 2>&1 &

    sleep 5
}

start_instance 8188 "Primary I2V"
start_instance 8189 "Upscaling"
start_instance 8190 "Backup"

echo "All instances started!"
echo "Primary: http://localhost:8188"
echo "Secondary: http://localhost:8189"
echo "Backup: http://localhost:8190"
```

---

## Monitoring Dashboard (CLI)

```python
#!/usr/bin/env python3
"""Real-time monitoring of ComfyUI instances"""

import requests
import time
import os
from datetime import datetime

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def get_instance_status(port):
    """Get status of ComfyUI instance"""
    url = f"http://127.0.0.1:{port}"

    try:
        # Check queue
        queue_response = requests.get(f"{url}/queue", timeout=2)
        queue_data = queue_response.json()

        running = len(queue_data.get("queue_running", []))
        pending = len(queue_data.get("queue_pending", []))

        # Check system stats
        stats_response = requests.get(f"{url}/system_stats", timeout=2)
        stats_data = stats_response.json()

        vram = stats_data.get("devices", [{}])[0].get("vram_used", 0) / 1024  # GB

        return {
            "status": "ONLINE",
            "running": running,
            "pending": pending,
            "vram_gb": round(vram, 2)
        }
    except:
        return {
            "status": "OFFLINE",
            "running": 0,
            "pending": 0,
            "vram_gb": 0
        }

def monitor_instances(instances):
    """Display real-time status of all instances"""
    while True:
        clear_screen()

        print("=" * 80)
        print(f"ComfyUI Instance Monitor - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 80)

        for name, config in instances.items():
            port = config["port"]
            purpose = config["purpose"]
            status = get_instance_status(port)

            status_color = "🟢" if status["status"] == "ONLINE" else "🔴"

            print(f"\n{status_color} {name.upper()} (Port {port}) - {purpose}")
            print(f"   Status: {status['status']}")
            print(f"   Queue: {status['running']} running, {status['pending']} pending")
            print(f"   VRAM: {status['vram_gb']} GB")

        print("\n" + "=" * 80)
        print("Press Ctrl+C to exit")

        time.sleep(5)

if __name__ == "__main__":
    INSTANCES = {
        "primary": {"port": 8188, "purpose": "I2V generation"},
        "secondary": {"port": 8189, "purpose": "Upscaling"},
        "backup": {"port": 8190, "purpose": "Standby"}
    }

    try:
        monitor_instances(INSTANCES)
    except KeyboardInterrupt:
        print("\n\nMonitoring stopped")
```

---

## Recovery Procedures

### Procedure 1: Soft Recovery (No Restart)

```python
def soft_recovery(port=8188):
    """Attempt recovery without restarting"""
    url = f"http://127.0.0.1:{port}"

    # 1. Clear queue
    print("[Recovery] Clearing queue...")
    try:
        requests.post(f"{url}/queue", json={"clear": True})
    except:
        pass

    # 2. Free memory
    print("[Recovery] Requesting garbage collection...")
    try:
        requests.post(f"{url}/free", json={"unload_models": True})
    except:
        pass

    # 3. Wait and check
    time.sleep(10)
    is_healthy, _ = check_comfyui_health(url)

    return is_healthy
```

### Procedure 2: Hard Recovery (Restart)

```python
def hard_recovery(port=8188, comfyui_path="E:/ComfyUI-Easy-Install/ComfyUI"):
    """Full restart recovery"""
    print("[Recovery] Hard recovery initiated...")

    try:
        restart_comfyui(comfyui_path, port)
        return True
    except Exception as e:
        print(f"[Recovery] Hard recovery failed: {e}")
        return False
```

### Procedure 3: Emergency Failover

```python
def emergency_failover(failed_port, backup_ports=[8189, 8190]):
    """Switch to backup instance"""
    print(f"[Failover] Port {failed_port} has failed")

    for backup_port in backup_ports:
        is_healthy, _ = check_comfyui_health(f"http://127.0.0.1:{backup_port}")

        if is_healthy:
            print(f"[Failover] Switching to port {backup_port}")
            return backup_port

    print("[Failover] No backup instances available!")
    return None
```

---

## Best Practices

1. **Always monitor health** - Check every 30-60 seconds
2. **Save queue state before restart** - Prevent work loss
3. **Keep backup instance ready** - Hot standby on different port
4. **Log all restart events** - For debugging patterns
5. **Use graceful termination** - Give ComfyUI time to save state
6. **Test failover regularly** - Don't wait for emergencies
7. **Monitor VRAM usage** - Memory leaks are common
8. **Set restart thresholds** - Auto-restart after N failures

---

## Troubleshooting

### ComfyUI won't start
- Check if port is already in use: `netstat -ano | findstr :8188`
- Verify Python environment is correct
- Check CUDA/ROCm drivers are installed
- Review startup logs for errors

### Instance keeps crashing
- Check VRAM usage - may be OOM
- Review workflows for memory leaks
- Update to latest ComfyUI version
- Check for corrupted models

### Queue stalls but process is running
- Workflow may have infinite loop
- Model download may be stuck
- Custom node may be hanging
- Try soft recovery first, then hard recovery

### Failover not working
- Verify backup instance is actually running
- Check network/firewall settings
- Ensure backup has same models loaded
- Test failover mechanism regularly
