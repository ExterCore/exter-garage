# Exter-Garage

Exter-Garage is an advanced **QBCore-based** garage system designed for **FiveM**, providing a seamless vehicle storage and retrieval experience for players. This script ensures efficient and immersive garage management, supporting multiple garage types and configurations.

## 🎯 Key Features
- 🚗 **QBCore Integration** - Fully compatible with the **QBCore** framework.
- 🏠 **Multiple Garage Types** - Supports private, public, and job-based garages.
- 🔄 **Vehicle Storage & Retrieval** - Allows players to store and retrieve their vehicles smoothly.
- 🔧 **Customizable Configurations** - Easily adjustable settings for garages, fees, and vehicle storage limits.
- 🛠️ **Optimized Performance** - Designed to minimize performance impact on the server.
- 🎨 **Modern UI Design** - A clean and responsive user interface.

## 📦 Installation

1. Download or clone the repository:
   ```sh
   git clone https://github.com/ExterCore/exter-garage.git
   ```
2. Move the `exter-garage` folder to the `[resources]` directory in your FiveM server.
3. Add the resource to your `server.cfg`:
   ```cfg
   ensure exter-garage
   ```
4. Restart your server and verify that the script is running correctly.

## ⚙️ Configuration

All settings can be modified in the **config.lua** file.

- **Adding a New Garage:**
  ```lua
  Config.Garages = {
      ["downtown"] = {
          name = "Downtown Garage",
          type = "public",
          coords = vector3(215.8, -810.1, 30.7),
          spawnPoints = {
              {coords = vector4(220.5, -798.9, 30.5, 180.0)}
          }
      }
  }
  ```
- **Setting Garage Fees & Restrictions:**
  Adjust fees and storage limits based on your server’s economy and balance.

## 📌 Requirements
- **[QBCore Framework](https://github.com/qbcore-framework)**
- **[Ox Inventory](https://github.com/overextended/ox_inventory) (Optional, if using an additional inventory system)**
- **[qb-garages (Legacy Version)](https://github.com/qbcore-framework/qb-garages) (Base compatibility)**
- **[cdn-fuel](https://github.com/cdn-fuel) (Required for fuel tracking)**

## 🛠️ Usage
- Players can store and retrieve vehicles at designated garages.
- Vehicle conditions, fuel levels, and damages are saved persistently.
- Different garage types (private, public, job-based) can be assigned as needed.

## 💡 Inspiration
This project was inspired by **various FiveM garage scripts**, with improvements tailored for the **ExterCore** ecosystem to enhance user experience and server performance.

## 📜 License
This project is licensed under the **MIT License**. See the `LICENSE` file for details.

## 🤝 Contributions
Contributions are welcome! To contribute:
1. Fork this repository.
2. Create a new branch (`feature-branch`).
3. Implement your changes and commit them.
4. Submit a Pull Request.

## 📞 Support
For issues or questions, open an **issue** in this repository or connect with the ExterCore community.

---
Created with ❤️ by [ExterCore](https://github.com/ExterCore).

