# DMARC-SPF-EPP-WHOis-records
PowerShell script to extract **DMARC**, **SPF**, **EPP**, and **WHOIS** records for a given domain using free APIs and local DNS queries.
This repository is designed for **email security audits**, **domain intelligence gathering**, and **defensive security assessments**.
---

## 📌 Features

- ✅ Extract DMARC records
- ✅ Extract SPF records
- ✅ Retrieve WHOIS information
- ✅ Retrieve EPP domain status
- ✅ Uses **free APIs**
- ✅ Supports **local DNS queries**
- ✅ Suitable for security engineers and SOC teams

## 🔧 Prerequisites

- Windows PowerShell **5.1+** or **PowerShell 7+**
- Internet connectivity
- A **free API key** from one of the following providers:
  - https://www.whoxy.com/
  - https://main.whoisxmlapi.com/
---

## 🔑 API Key Setup

1. Register for a **free account** using one of the links above.
2. Generate your **API key**.
3. Open the PowerShell script (`.ps1` file).
4. Replace the placeholder value:
```powershell
$ApiKey = "REPLACE_WITH_YOUR_API_KEY"
````

> ⚠️ Do **not** commit real API keys to public repositories.

***
## 📦 Required PowerShell Modules

Ensure required modules are installed:
```powershell
Install-Module -Name DnsClient -Scope CurrentUser
```

If prompted, allow installations from PSGallery.

***

## ▶️ Usage
1.  Open PowerShell
2.  Navigate to the script directory:

```powershell
cd path\to\PS_script
```
3.  Run the script:

```powershell
.\DMARC_SPF_WHOIS.ps1
```

4.  Enter the domain name when prompted.

***

## 📄 Output

The script returns:

*   DMARC policy and reporting details
*   SPF record validation
*   WHOIS domain registration data
*   EPP domain status codes
*   Clean, readable console output

***

## 🛡️ Use Cases

*   Email security posture reviews
*   DMARC/SPF misconfiguration checks
*   Phishing readiness assessments
*   Domain reconnaissance
*   Blue Team / SOC investigations

***

## ⚠️ Disclaimer

This script is intended **for authorized security assessments only**.  
Use it **only on domains you own or have explicit permission to test**.

The author assumes **no liability** for misuse.

***
## 🤝 Contributing
Contributions are welcome!
1.  Fork the repository
2.  Create a feature branch
3.  Submit a pull request
4.  Add documentation for any changes
***
## 📜 License
This project is provided **as-is**, without warranty of any kind.

