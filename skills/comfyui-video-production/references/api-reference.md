# ComfyUI API Reference

Complete guide to ComfyUI's REST API for programmatic workflow submission and monitoring.

---

## Base URL

```
http://127.0.0.1:8188
```

For multiple instances:
- Primary: `http://127.0.0.1:8188`
- Secondary: `http://127.0.0.1:8189`
- Backup: `http://127.0.0.1:8190`

---

## Core Endpoints

### GET /queue

Get current queue status

**Response:**
```json
{
  "queue_running": [
    ["prompt_id", 3, {"prompt": {...}, "extra_data": {...}}]
  ],
  "queue_pending": [
    ["prompt_id", 2, {"prompt": {...}, "extra_data": {...}}]
  ]
}
```

### POST /prompt

Submit new workflow to queue

**Request:**
```json
{
  "prompt": {
    "1": {
      "class_type": "LoadImage",
      "inputs": {"image": "keyframe_01.png"}
    },
    "2": {
      "class_type": "UNETLoader",
      "inputs": {"unet_name": "wan2.2_14B.safetensors"}
    }
    // ... more nodes
  },
  "client_id": "optional_client_id"
}
```

**Response:**
```json
{
  "prompt_id": "abc123-def456-ghi789",
  "number": 42,
  "node_errors": {}
}
```

### GET /history

Get execution history

**Response:**
```json
{
  "prompt_id_1": {
    "prompt": {...},
    "outputs": {
      "14": {
        "images": [
          {
            "filename": "Sage_NSFW_Video_00001.mp4",
            "subfolder": "",
            "type": "output"
          }
        ]
      }
    },
    "status": {
      "status_str": "success",
      "completed": true,
      "messages": []
    }
  }
}
```

### GET /system_stats

Get system information

**Response:**
```json
{
  "system": {
    "os": "nt",
    "python_version": "3.11.5",
    "embedded_python": false
  },
  "devices": [
    {
      "name": "NVIDIA GeForce RTX 5090",
      "type": "cuda",
      "index": 0,
      "vram_total": 34359738368,
      "vram_free": 12884901888
    }
  ]
}
```

### POST /free

Unload models and free VRAM

**Request:**
```json
{
  "unload_models": true,
  "free_memory": true
}
```

### POST /interrupt

Interrupt current execution

**Request:** (empty or `{}`)

---

## Python API Client

### Basic Client

```python
import requests
import json
import time

class ComfyUIClient:
    def __init__(self, url="http://127.0.0.1:8188"):
        self.url = url

    def submit_workflow(self, workflow):
        """Submit workflow and return prompt_id"""
        data = json.dumps({"prompt": workflow})
        response = requests.post(
            f"{self.url}/prompt",
            data=data,
            headers={'Content-Type': 'application/json'}
        )
        return response.json()

    def get_queue(self):
        """Get current queue status"""
        response = requests.get(f"{self.url}/queue")
        return response.json()

    def get_history(self, prompt_id=None):
        """Get execution history"""
        url = f"{self.url}/history"
        if prompt_id:
            url += f"/{prompt_id}"
        response = requests.get(url)
        return response.json()

    def wait_for_completion(self, prompt_id, timeout=600, poll_interval=5):
        """Wait for workflow to complete"""
        start = time.time()

        while time.time() - start < timeout:
            history = self.get_history(prompt_id)

            if prompt_id in history:
                status = history[prompt_id].get('status', {})
                if status.get('completed'):
                    return history[prompt_id]

            time.sleep(poll_interval)

        raise TimeoutError(f"Workflow {prompt_id} did not complete in {timeout}s")

    def get_output_files(self, prompt_id):
        """Extract output files from completed workflow"""
        history = self.get_history(prompt_id)

        if prompt_id not in history:
            return []

        outputs = history[prompt_id].get('outputs', {})
        files = []

        for node_id, node_output in outputs.items():
            if 'images' in node_output:
                for image in node_output['images']:
                    files.append({
                        'filename': image['filename'],
                        'subfolder': image.get('subfolder', ''),
                        'type': image['type']
                    })

        return files

    def interrupt(self):
        """Interrupt current execution"""
        response = requests.post(f"{self.url}/interrupt")
        return response.status_code == 200

    def free_memory(self):
        """Unload models and free VRAM"""
        response = requests.post(
            f"{self.url}/free",
            json={"unload_models": True, "free_memory": True}
        )
        return response.status_code == 200
```

### Usage Example

```python
# Initialize client
client = ComfyUIClient("http://127.0.0.1:8188")

# Define workflow
workflow = {
    "1": {
        "class_type": "LoadImage",
        "inputs": {"image": "keyframe_01.png"}
    },
    "2": {
        "class_type": "UNETLoader",
        "inputs": {"unet_name": "wan2.2_14B.safetensors"}
    }
    # ... more nodes
}

# Submit
result = client.submit_workflow(workflow)
prompt_id = result['prompt_id']

print(f"Submitted: {prompt_id}")

# Wait for completion
try:
    completed = client.wait_for_completion(prompt_id, timeout=300)
    print("✓ Completed successfully")

    # Get output files
    files = client.get_output_files(prompt_id)
    for f in files:
        print(f"Output: {f['filename']}")

except TimeoutError:
    print("✗ Workflow timed out")
    client.interrupt()
```

---

## Batch Processing

### Queue Multiple Workflows

```python
def queue_batch(client, workflows, stagger_delay=2):
    """
    Queue multiple workflows with staggered submission

    Args:
        client: ComfyUIClient instance
        workflows: List of workflow dicts
        stagger_delay: Seconds to wait between submissions

    Returns:
        List of prompt_ids
    """
    prompt_ids = []

    for i, workflow in enumerate(workflows):
        print(f"[Batch] Submitting {i+1}/{len(workflows)}...")

        result = client.submit_workflow(workflow)
        prompt_id = result['prompt_id']
        prompt_ids.append(prompt_id)

        if i < len(workflows) - 1:  # Don't wait after last one
            time.sleep(stagger_delay)

    return prompt_ids

def wait_for_batch(client, prompt_ids, timeout=600):
    """
    Wait for all workflows in batch to complete

    Args:
        client: ComfyUIClient instance
        prompt_ids: List of prompt IDs
        timeout: Max wait time per workflow

    Returns:
        Dict of {prompt_id: result}
    """
    results = {}

    for prompt_id in prompt_ids:
        print(f"[Batch] Waiting for {prompt_id}...")

        try:
            result = client.wait_for_completion(prompt_id, timeout)
            results[prompt_id] = result
            print(f"[Batch] ✓ {prompt_id} completed")
        except TimeoutError:
            print(f"[Batch] ✗ {prompt_id} timed out")
            results[prompt_id] = None

    return results

# Example usage
keyframes = [
    "keyframe_01.png",
    "keyframe_02.png",
    "keyframe_03.png",
    "keyframe_04.png",
    "keyframe_05.png"
]

workflows = [
    create_i2v_workflow(kf, motion_prompt)
    for kf, motion_prompt in zip(keyframes, motion_prompts)
]

# Submit batch
client = ComfyUIClient()
prompt_ids = queue_batch(client, workflows, stagger_delay=3)

# Wait for all
results = wait_for_batch(client, prompt_ids, timeout=300)

# Check success rate
completed = sum(1 for r in results.values() if r is not None)
print(f"\n[Batch] {completed}/{len(results)} workflows completed")
```

---

## Advanced: WebSocket Monitoring

For real-time progress updates, use WebSocket connection:

```python
import websocket
import json
import threading

class ComfyUIWebSocketMonitor:
    def __init__(self, url="ws://127.0.0.1:8188/ws"):
        self.url = url
        self.ws = None
        self.callbacks = {}

    def on_message(self, ws, message):
        """Handle incoming messages"""
        data = json.loads(message)

        msg_type = data.get('type')
        if msg_type in self.callbacks:
            self.callbacks[msg_type](data)

    def on_error(self, ws, error):
        print(f"[WebSocket] Error: {error}")

    def on_close(self, ws, close_status_code, close_msg):
        print("[WebSocket] Connection closed")

    def register_callback(self, message_type, callback):
        """Register callback for message type"""
        self.callbacks[message_type] = callback

    def connect(self):
        """Connect to WebSocket"""
        self.ws = websocket.WebSocketApp(
            self.url,
            on_message=self.on_message,
            on_error=self.on_error,
            on_close=self.on_close
        )

        # Run in background thread
        thread = threading.Thread(target=self.ws.run_forever)
        thread.daemon = True
        thread.start()

    def disconnect(self):
        """Disconnect from WebSocket"""
        if self.ws:
            self.ws.close()

# Example usage
monitor = ComfyUIWebSocketMonitor()

def on_progress(data):
    """Called when progress updates received"""
    value = data.get('data', {}).get('value', 0)
    max_val = data.get('data', {}).get('max', 100)
    print(f"Progress: {value}/{max_val} ({value/max_val*100:.1f}%)")

def on_execution_start(data):
    prompt_id = data.get('data', {}).get('prompt_id')
    print(f"Execution started: {prompt_id}")

def on_execution_complete(data):
    prompt_id = data.get('data', {}).get('prompt_id')
    print(f"Execution completed: {prompt_id}")

monitor.register_callback('progress', on_progress)
monitor.register_callback('execution_start', on_execution_start)
monitor.register_callback('executed', on_execution_complete)

monitor.connect()

# Submit workflows...
# Real-time progress will be printed

# When done
monitor.disconnect()
```

---

## Error Handling

### Workflow Validation

```python
def validate_workflow(workflow):
    """Basic workflow validation before submission"""
    errors = []

    # Check required structure
    if not isinstance(workflow, dict):
        errors.append("Workflow must be a dictionary")
        return errors

    # Check each node
    for node_id, node in workflow.items():
        if 'class_type' not in node:
            errors.append(f"Node {node_id}: Missing class_type")

        if 'inputs' not in node:
            errors.append(f"Node {node_id}: Missing inputs")

    return errors

# Example usage
errors = validate_workflow(workflow)
if errors:
    print("Workflow validation failed:")
    for error in errors:
        print(f"  - {error}")
else:
    # Submit workflow
    client.submit_workflow(workflow)
```

### Retry Logic

```python
def submit_with_retry(client, workflow, max_retries=3):
    """Submit workflow with automatic retry on failure"""
    for attempt in range(max_retries):
        try:
            result = client.submit_workflow(workflow)
            return result
        except Exception as e:
            print(f"Attempt {attempt+1} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(5)  # Wait before retry
            else:
                raise

# Example usage
try:
    result = submit_with_retry(client, workflow, max_retries=3)
    print(f"Submitted: {result['prompt_id']}")
except Exception as e:
    print(f"Failed after 3 attempts: {e}")
```

---

## Best Practices

1. **Always validate workflows** before submission
2. **Use timeouts** when waiting for completion
3. **Implement retry logic** for transient failures
4. **Monitor queue depth** to avoid overload
5. **Free memory** between large batches
6. **Use WebSocket** for real-time progress tracking
7. **Handle errors gracefully** with fallback strategies
8. **Stagger batch submissions** to avoid overwhelming the server

---

## Common Issues

### Issue: Connection refused
**Cause:** ComfyUI not running or wrong port
**Fix:** Check if ComfyUI is running on expected port

### Issue: Workflow validation errors
**Cause:** Invalid node inputs or missing required fields
**Fix:** Validate workflow structure before submission

### Issue: Timeout waiting for completion
**Cause:** Workflow taking too long or stuck
**Fix:** Increase timeout or use interrupt endpoint

### Issue: Queue depth growing
**Cause:** Submitting faster than processing
**Fix:** Implement backpressure - check queue before submitting

### Issue: VRAM out of memory
**Cause:** Models not unloading between workflows
**Fix:** Call `/free` endpoint periodically
