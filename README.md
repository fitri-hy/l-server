# L-Server CLI

**"Portable Local Server, Full Control!"**

L-Server CLI is a **portable local server** designed for Windows to simplify local web application development. All services run directly from the project folder without global installation, making it perfect for portable development environments.

## ⚙️ Available Services

- 🐬 **MariaDB**  
- 🐘 **PHP & PHP-FPM**  
- 🚀 **NGINX**  
- 🗄️ **phpMyAdmin**  
- 🗂 **File Browser**  

## ⚡ How to Use

1. Clone the repository or unzip the project folder to your local machine.  
2. Open **PowerShell / Command Prompt** and run:  
```powershell
./run.bat
````

3. Choose an option from the CLI menu:

| Menu | Function                                               |
| ---- | ------------------------------------------------------ |
| 1    | Start Services (MariaDB, PHP-FPM, NGINX, File Browser) |
| 2    | Stop Services                                          |
| 3    | Check Service Status                                   |
| 4    | Help (Account Info)                                    |
| 5    | Exit CLI                                               |

4. Access services via browser:

* **File Browser** → [http://localhost:8081](http://localhost:8081)
* **PHPMyAdmin** → [http://localhost:8080/phpmyadmin](http://localhost:8080/phpmyadmin)
* **NGINX Web Server** → [http://localhost:8080](http://localhost:8080)

## 🤝 Contributing

Contributions are welcome! Please feel free to fork the repository, create an issue, or submit a pull request for new features or improvements.