# 💳 Fintech Wallet App

A full-featured **digital wallet application** built with **Flutter + Spring Boot**, designed to simulate real-world fintech systems like Wise, PayPal, and banking apps.

---

## 🚀 Features

### 🔐 Authentication

* JWT-based Login & Registration
* Secure API communication

### 👤 Profile Management

* User profile creation & updates
* Persistent user data

### 💰 Wallet System

* Add money to wallet
* Real-time balance updates
* Transaction-safe operations

### 💸 Money Transfer

* Send money to other users
* Receive money instantly
* Transaction validation & status tracking

### 📊 Transaction History

* Detailed transaction logs
* Filter and track all activities

### 🌍 Remittance Engine (Advanced)

* Compare exchange rates across providers
* Real-time currency conversion (Live API)
* Best provider selection (optimization logic)

### 🔔 Real-Time Notifications

* WebSocket-based live transaction updates
* Instant alerts for incoming transfers

---

## 🏗️ Tech Stack

### Frontend (Mobile)

* Flutter
* Provider (State Management)
* REST API Integration

### Backend

* Spring Boot
* JWT Authentication
* PostgreSQL
* WebSocket (STOMP)

### External Integrations

* Exchange Rate API (Live currency rates)

---

## 📱 Screens

* Login / Register
* Dashboard
* Wallet Overview
* Send Money
* Transaction History
* Remittance Comparison

---

## ⚙️ Architecture

```text
Flutter App (UI)
     ↓
Provider (State Management)
     ↓
REST API
     ↓
Spring Boot Backend
     ↓
Database + External APIs
```


---

## 🔑 Environment Setup

Create `.env` / `application.properties`:

```properties
exchange.api.key=YOUR_API_KEY
jwt.secret=YOUR_SECRET
```

---

## 📈 Future Improvements

* KYC Verification System
* Multi-currency wallet
* Payment gateway integration
* AI-based fraud detection
* Advanced analytics dashboard

---

---

## ⭐ Author

**Badusha P**

---
