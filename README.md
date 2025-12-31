# CoinoRotator 🪙🔄

**CoinoRotator** is an automated Swift-based utility for macOS designed to maintain network activity and manage transaction rotation for a **Coino (CNO)** node. It interacts with the local wallet via the JSON-RPC protocol.

## ✨ Features
* **Automated Rotation:** Generates a new internal address every 60 seconds.
* **Scheduled Transactions:** Automatically sends a fixed amount (1.0 CNO) to the newly generated address.
* **Real-time Logging:** Provides a clean console output with timestamps, cycle counts, and truncated Transaction IDs (TXIDs).
* **Native Performance:** Written in Swift for high efficiency and low resource usage on macOS.

## ⚙️ How It Works
The script utilizes a `DispatchSourceTimer` to execute the following logic every minute:
1. Calls the `getnewaddress` RPC method.
2. Executes `sendtoaddress` using the new address and the predefined amount.
3. Logs the result to the Terminal for monitoring.

## 🚀 Quick Start

### 1. Prerequisites
* **macOS** with Xcode Command Line Tools installed.
* A running **Coino Node** (`coinod` or GUI wallet) with RPC enabled.
* Ensure your `coino.conf` allows connections from `127.0.0.1`.

### 2. Run the Script
1. Clone or download `CoinoRotator.swift` to your Desktop.
2. Open **Terminal** and navigate to the directory:
   ```bash
   cd ~/Desktop
