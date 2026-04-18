const API_BASE = '/api'

export async function fetchOptions() {
  const response = await fetch(`${API_BASE}/options`)
  return response.json()
}

export async function saveConfiguration(config) {
  const response = await fetch(`${API_BASE}/configurations`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(config)
  })
  return response.json()
}

export async function getConfiguration(id) {
  const response = await fetch(`${API_BASE}/configurations/${id}`)
  if (!response.ok) return null
  return response.json()
}

export async function createOrder(order) {
  const response = await fetch(`${API_BASE}/orders`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(order)
  })
  return response.json()
}
