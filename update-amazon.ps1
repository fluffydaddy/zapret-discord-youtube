# Set UTF-8 output encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Path to save the IP list
$listPath = Join-Path -Path $PSScriptRoot -ChildPath "lists\custom\ipset-amazon.txt"

# URL to fetch the raw IP list
$url = "https://raw.githubusercontent.com/V3nilla/IPSets-For-Bypass-in-Russia/refs/heads/main/ipset-amazon.txt"

# List of IP addresses always added.
$manualIPs = @(
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
