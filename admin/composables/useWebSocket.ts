// composables/useWebSocket.ts
import { ref, onUnmounted } from 'vue'
import type { Socket } from 'socket.io-client'

type EventHandler = (...args: unknown[]) => void

export function useWebSocket() {
  const socket = ref<Socket | null>(null)
  const isConnected = ref(false)
  const config = useRuntimeConfig()

  async function connect(path: string = '') {
    if (!process.client) return
    // Dynamically import socket.io-client to avoid SSR issues
    const { io } = await import('socket.io-client')
    const wsUrl = config.public.wsUrl as string

    socket.value = io(wsUrl + path, {
      transports: ['websocket'],
      autoConnect: true,
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 2000,
      auth: {
        token: useCookie('zekdrive_token').value || '',
      },
    })

    socket.value.on('connect', () => {
      isConnected.value = true
    })

    socket.value.on('disconnect', () => {
      isConnected.value = false
    })
  }

  function on(event: string, handler: EventHandler) {
    socket.value?.on(event, handler)
  }

  function off(event: string, handler?: EventHandler) {
    if (handler) {
      socket.value?.off(event, handler)
    } else {
      socket.value?.off(event)
    }
  }

  function emit(event: string, data?: unknown) {
    socket.value?.emit(event, data)
  }

  function disconnect() {
    socket.value?.disconnect()
    socket.value = null
    isConnected.value = false
  }

  onUnmounted(() => {
    disconnect()
  })

  return {
    socket,
    isConnected,
    connect,
    on,
    off,
    emit,
    disconnect,
  }
}
