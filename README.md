# Domain DNS and WHOIS inventory

Two PowerShell workflows export domain information from an Excel workbook. Choose DNS-only mode for SPF/DMARC presence and policy checks, or API mode for WHOIS/EPP and registrant enrichment alongside DNS records.

| Script | Inputs | External dependency |
| --- | --- | --- |
| [Invoke-DnsAudit.ps1](scripts/Invoke-DnsAudit.ps1) | Domain values in a chosen worksheet column and row range | Configured DNS resolver; no API key |
| [Invoke-WhoisDnsAudit.ps1](scripts/Invoke-WhoisDnsAudit.ps1) | First worksheet with a `Domain` column | WhoisXML API account/key and DNS resolver |

## Requirements

- Windows with PowerShell and the `Resolve-DnsName` cmdlet. These scripts are not cross-platform DNS tools.
- The [ImportExcel module](https://github.com/dfinke/ImportExcel). Microsoft Excel itself is not required.
- An existing output directory and a different output workbook path from the input.

```powershell
git clone https://github.com/Hellfire4959/DMARC-SPF-EPP-WHOis-records.git
Set-Location DMARC-SPF-EPP-WHOis-records
Install-Module ImportExcel -Scope CurrentUser
New-Item -ItemType Directory -Force output
```

The scripts check prerequisites and do not install modules automatically.

## DNS-only mode

Put domains in column A, with a header in row 1. Run:

```powershell
.\scripts\Invoke-DnsAudit.ps1 -InputPath .\domains.xlsx -OutputPath .\output\dns-audit.xlsx
```

Defaults: first worksheet, column 1, starting at row 2 through the last used row. To choose a range:

```powershell
.\scripts\Invoke-DnsAudit.ps1 -InputPath .\domains.xlsx -OutputPath .\output\dns-audit.xlsx -DomainColumn 2 -StartRow 2 -EndRow 100
```

This mode preserves each selected row, normalizes common URL/email-like inputs, converts internationalized domain names to ASCII, and exports the original input, cleaned lookup name, timestamp, TXT records and summary statuses. The output worksheet is `SPF DMARC Audit`. Its content is replaced on a repeated run.

SPF/DMARC labels are basic record-presence and policy-string checks, not full RFC validation. Resolver failures currently produce empty lookup results, so a reported missing record needs confirmation before a configuration decision. The script uses operating-system DNS behavior without custom retry or timeout settings. It does not retrieve DKIM, WHOIS or EPP data.

## WHOIS + DNS mode

The first worksheet needs a column named **Domain**. Supply your key through the process environment or the `-ApiKey` parameter:

```powershell
# Set WHOISXML_API_KEY in your shell or secret manager first.
.\scripts\Invoke-WhoisDnsAudit.ps1 -InputPath .\domains.xlsx -OutputPath .\output\whois-audit.xlsx
```

Each nonblank domain produces an API request. The output includes domain/EPP status, SPF/DMARC values, registrant fields, nameservers and abuse-contact information when the provider supplies them. Blank domains are skipped. API errors stop the run; this mode does not implement retries or per-row API-error output. DNS failures can appear as missing records in this legacy workflow. API availability, credits and redacted registration data affect completeness.

The original extensionless files `Free script using local DNS` and `PS_script` now live under `scripts/` with `.ps1` extensions and explicit path parameters.

## Validation and contributions

GitHub Actions parses both scripts on Windows to catch syntax errors. This is syntax validation, not a live DNS/Excel/WhoisXML integration test. A full run requires Windows, ImportExcel, a representative workbook, and API access for WHOIS mode. Include sanitized input and expected output when proposing changes.
