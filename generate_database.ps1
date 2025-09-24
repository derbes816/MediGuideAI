[CmdletBinding()]
param(
    [string]$SqlitePath      = "C:\sqlite\sqlite3.exe",
    [string]$CsvSourcePath   = (Join-Path $PSScriptRoot "data\csv"),
    [string]$DbOutputPath    = (Join-Path $PSScriptRoot "data\db"),
    [string]$AssetsPath      = (Join-Path $PSScriptRoot "app\src\main\assets\database")
)

function Invoke-Sqlite {
    param(
        [string]$DbFile,
        [Parameter(ValueFromPipeline)]$Query
    )
    process {
        $output = $Query | & $SqlitePath $DbFile
        if ($LASTEXITCODE -ne 0) {
            throw "Ошибка выполнения SQLite в файле '$DbFile'. Код выхода: $LASTEXITCODE. Вывод: $output"
        }
        return $output
    }
}

Write-Host "--- 🚀 Начало подготовки ---"
if (-not (Test-Path $SqlitePath)) { throw "Не найден sqlite3.exe: $SqlitePath" }
if (-not (Test-Path $CsvSourcePath)) { throw "Не найдена папка с CSV: $CsvSourcePath" }

if (-not (Test-Path $DbOutputPath)) { New-Item -ItemType Directory -Path $DbOutputPath | Out-Null; Write-Host "✅ Создана папка: $DbOutputPath" -ForegroundColor Green }
if (-not (Test-Path $AssetsPath))   { New-Item -ItemType Directory -Path $AssetsPath -Force | Out-Null; Write-Host "✅ Создана папка: $AssetsPath" -ForegroundColor Green }

Remove-Item "$AssetsPath\*.db" -ErrorAction SilentlyContinue
Write-Host "🧹 Папка assets очищена от старых .db файлов."

$totalStart = Get-Date
$csvFiles = Get-ChildItem -Path $CsvSourcePath -Filter "raw_faq_*.csv" -File

if ($csvFiles.Count -eq 0) {
    Write-Warning "В папке '$CsvSourcePath' не найдено ни одного CSV файла по шаблону 'raw_faq_*.csv'."
    return
}

Write-Host "📂 Найдено CSV для обработки: $($csvFiles.Count). Запускаем параллельную обработку..."
Write-Host "---"

$results = $csvFiles | ForEach-Object -Parallel {
    $file = $_
    $threadId = $PID
    $resultObject = [PSCustomObject]@{
        FileName     = $file.Name
        DatabaseName = ''
        Status       = 'Ошибка'
        RecordCount  = 0
        SizeMB       = 0
        DurationSec  = 0
        ErrorMessage = ''
    }
    
    $fileStart = Get-Date

    try {
        if ((Get-Content $file.FullName -TotalCount 2).Count -le 1) {
            $resultObject.Status = 'Пропущен (пустой)'
            $resultObject.ErrorMessage = 'Файл пустой или содержит только заголовок.'
            return $resultObject
        }

        $lang   = $file.BaseName -replace '^raw_faq_', ''
        $dbName = "faq_${lang}.db"
        $dbFile = Join-Path $using:DbOutputPath $dbName
        $resultObject.DatabaseName = $dbName

        Write-Host "[Поток $threadId] 🔄 Обработка: $($file.Name) → $dbName"

        if (Test-Path $dbFile) { Remove-Item $dbFile -Force }

        @"
CREATE TABLE FaqEntity (
    id INTEGER NOT NULL PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category TEXT,
    tags TEXT
);
CREATE VIRTUAL TABLE FaqFts USING fts5(
    question,
    answer,
    tags,
    content='FaqEntity',
    content_rowid='id',
    tokenize='porter unicode61'
);
"@ | Invoke-Sqlite -DbFile $dbFile -using:SqlitePath

        $safeCsvPath = $file.FullName.Replace("'", "''")
        ".mode csv`n.separator ,`n.import --skip 1 '$safeCsvPath' FaqEntity" | Invoke-Sqlite -DbFile $dbFile -using:SqlitePath

        "INSERT INTO FaqFts(FaqFts) VALUES('rebuild');" | Invoke-Sqlite -DbFile $dbFile -using:SqlitePath
        
        "VACUUM;" | Invoke-Sqlite -DbFile $dbFile -using:SqlitePath

        $destinationPath = Join-Path $using:AssetsPath $dbName
        Copy-Item $dbFile -Destination $destinationPath -Force
        
        $recordCount = ("SELECT COUNT(*) FROM FaqEntity;" | Invoke-Sqlite -DbFile $dbFile -using:SqlitePath).Trim()
        $sizeMB = [math]::Round((Get-Item $dbFile).Length / 1MB, 2)

        $resultObject.Status = '✅ Успешно'
        $resultObject.RecordCount = [int]$recordCount
        $resultObject.SizeMB = $sizeMB
    }
    catch {
        $resultObject.ErrorMessage = $_.ToString()
    }
    finally {
        $resultObject.DurationSec = [math]::Round(((Get-Date) - $fileStart).TotalSeconds, 2)
    }

    return $resultObject

} -ThrottleLimit ([System.Environment]::ProcessorCount)


$totalElapsed = (Get-Date) - $totalStart
Write-Output "`n--- ✅ Все операции завершены ---"
Write-Output "⏱️ Общее время выполнения: $([math]::Round($totalElapsed.TotalSeconds, 2)) сек."

$success = $results | Where-Object { $_.Status -eq '✅ Успешно' }
$skipped = $results | Where-Object { $_.Status -like 'Пропущен*' }
$errors  = $results | Where-Object { $_.Status -eq 'Ошибка' }

if ($success) {
    Write-Host "`n--- Отчёт об успешно созданных базах ---" -ForegroundColor Green
    $success | Format-Table FileName, DatabaseName, RecordCount, SizeMB, DurationSec -AutoSize
}

if ($skipped) {
    Write-Host "`n--- Пропущенные файлы ---" -ForegroundColor Yellow
    $skipped | Format-Table FileName, Status, ErrorMessage -AutoSize -Wrap
}

if ($errors) {
    Write-Host "`n--- ❌ ОБНАРУЖЕНЫ ОШИБКИ ---" -ForegroundColor Red
    foreach ($err in $errors) {
        Write-Host "Файл: $($err.FileName)" -ForegroundColor Red
        Write-Host "Ошибка: $($err.ErrorMessage)" -ForegroundColor Red
        Write-Host "---"
    }
}
