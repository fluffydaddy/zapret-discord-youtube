# Set UTF-8 output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Path to save the IP list
$listPath = Join-Path -Path $PSScriptRoot -ChildPath "lists\custom\ipset-cloudflare.txt"

# URL to fetch the raw IP list
$url = "https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-cloudflare.txt"

# List of IP addresses always added.
$manualIPs = @(
    "13.248.195.177",
    "99.83.130.90",
    "103.21.244.0/22",
    "108.162.192.0/18",
    "188.114.96.0/20",
    "162.158.0.0/15",
    "172.64.0.0/13",
    "3.64.0.0/12",
    "54.70.78.0/24",
    "142.250.74.0/24",
    "172.217.18.0/24",
    "216.58.214.0/24",
    "185.40.64.0/23",
    "185.40.66.0/24",
    "13.248.195.0/24",
    "99.83.130.0/24",
    "99.83.128.0/20",
    "18.165.180.0/22",
    "44.224.0.0/11"
)

# Try to fetch and save the IP list
try {
    $response = Invoke-WebRequest -Uri $url -TimeoutSec 10 -UseBasicParsing

    if ($response.StatusCode -eq 200 -and $response.Content) {
        # Ensure the directory exists
        $dir = Split-Path -Path $listPath
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir | Out-Null
        }

        # Combine remote IP list with manual IPs
        $remoteIPs = $response.Content -split "`r?`n"
        $allIPs = $remoteIPs + $manualIPs

        # Remove empty lines and duplicates
        $uniqueIPs = $allIPs | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Sort-Object -Unique

        # Save to file
        $uniqueIPs | Out-File -FilePath $listPath -Encoding utf8

        # Count lines (IPs)
        Write-Host "[INFO] IP list updated successfully. $($uniqueIPs.Count) IPs saved."
    }
    else {
        Write-Host "[ERROR] Failed to fetch IP list. Status code: $($response.StatusCode)"
        exit 1
    }
}
catch {
    Write-Host "[ERROR] Request failed. Timeout or other error."
    Write-Host "[INFO] Retaining current IP list."
    exit 1
}
