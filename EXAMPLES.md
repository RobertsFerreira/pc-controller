# PC Controller WebSocket API Examples

Exemplos atualizados com o formato real de mensagens aceito pelo servidor.

## Conexão WebSocket

Conecte em: `ws://localhost:3000/ws`

## Formato de Request (obrigatório)

Todas as mensagens devem usar envelope global com `module` e `payload`:

```json
{
  "module": "audio",
  "payload": {
    "action": "devices_list"
  }
}
```

Sem `payload`, o servidor retorna erro `400`.

## Ações do módulo `audio`

### 1) Listar dispositivos de saída

**Request:**

```json
{
  "module": "audio",
  "payload": {
    "action": "devices_list"
  }
}
```

**Response:**

```json
{
  "data": [
    {
      "id": "{DEVICE_ID}",
      "name": "Speakers (Realtek Audio)"
    }
  ],
  "headers": {
    "timestamp": 1737100800,
    "count": 1
  }
}
```

### 2) Listar sessões de um dispositivo

**Request:**

```json
{
  "module": "audio",
  "payload": {
    "action": "session_list",
    "device_id": "{DEVICE_ID}"
  }
}
```

**Response:**

```json
{
  "data": [
    {
      "id": "11111111-1111-1111-1111-111111111111",
      "display_name": "Spotify",
      "volume_level": 75.0,
      "state": "active",
      "muted": false
    }
  ],
  "headers": {
    "timestamp": 1737100800,
    "count": 1
  }
}
```

### 3) Obter volume master

**Request:**

```json
{
  "module": "audio",
  "payload": {
    "action": "get_volume"
  }
}
```

**Response:**

```json
{
  "data": 55.0,
  "headers": {
    "timestamp": 1737100800
  }
}
```

### 4) Definir volume de um grupo/sessão

`volume` deve estar entre `0.0` e `100.0`.

**Request:**

```json
{
  "module": "audio",
  "payload": {
    "action": "set_group_volume",
    "device_id": "{DEVICE_ID}",
    "group_id": "11111111-1111-1111-1111-111111111111",
    "volume": 50.0
  }
}
```

**Response:**

```json
{
  "data": "Group volume set successfully",
  "headers": {
    "timestamp": 1737100800
  }
}
```

## Estados de sessão

- `active`
- `inactive`
- `expired`

## Formato de erro

```json
{
  "code": 400,
  "message": "Invalid request format"
}
```

Campos:

- `code`: codigo HTTP-like (`400`, `404`, `500`)
- `message`: descrição do erro
- `details`: opcional; pode nao estar presente

## Erros comuns

### JSON invalido

```text
{invalid json}
```

Resposta esperada:

```json
{
  "code": 400,
  "message": "Invalid request format"
}
```

### Payload ausente

**Request:**

```json
{
  "module": "audio"
}
```

Resposta esperada (`message` contem "Payload is missing"):

```json
{
  "code": 400,
  "message": "Payload is missing in the request"
}
```

### Modulo nao registrado

**Request:**

```json
{
  "module": "display",
  "payload": {
    "action": "get_volume"
  }
}
```

Resposta esperada:

```json
{
  "code": 404,
  "message": "Resource not found"
}
```

### Volume fora do intervalo

Se `volume < 0.0` ou `volume > 100.0`, a desserialização da action falha e o servidor retorna `400`.

Exemplo de request invalida:

```json
{
  "module": "audio",
  "payload": {
    "action": "set_group_volume",
    "device_id": "{DEVICE_ID}",
    "group_id": "{GROUP_ID}",
    "volume": 100.1
  }
}
```

## Exemplo JavaScript

```javascript
const ws = new WebSocket('ws://localhost:3000/ws');

ws.onopen = () => {
  ws.send(JSON.stringify({
    module: 'audio',
    payload: { action: 'devices_list' }
  }));
};

ws.onmessage = (event) => {
  const msg = JSON.parse(event.data);

  if (msg.code) {
    console.error('Erro:', msg.code, msg.message);
    return;
  }

  console.log('Resposta:', msg);
};
```

## Exemplo Python

```python
import asyncio
import json
import websockets

async def main():
    uri = "ws://localhost:3000/ws"
    async with websockets.connect(uri) as ws:
        await ws.send(json.dumps({
            "module": "audio",
            "payload": {"action": "get_volume"}
        }))

        response = await ws.recv()
        print(json.loads(response))

asyncio.run(main())
```

## Exemplo websocket

```bash
# Listar dispositivos
echo '{"module":"audio","payload":{"action":"devices_list"}}' | websocket ws://localhost:3000/ws

# Listar sessoes
echo '{"module":"audio","payload":{"action":"session_list","device_id":"{DEVICE_ID}"}}' | websocket ws://localhost:3000/ws

# Definir volume de grupo
echo '{"module":"audio","payload":{"action":"set_group_volume","device_id":"{DEVICE_ID}","group_id":"{GROUP_ID}","volume":75.0}}' | websocket ws://localhost:3000/ws
```

## Observações

- `device_id` vem do retorno de `devices_list`.
- `group_id` vem de `session_list` (campo `id`).
- A conexão WebSocket e persistente; envie varias requests na mesma sessão.
- Consulte `README.md` para considerações de segurança (autenticação, exposição de rede e TLS/WSS).
