function Read-ApacheLog
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Path
    )

    Get-Content -Path $Path | Foreach-Object {
       # combined format
       if ($_ -notmatch "^(?<Host>.*?) (?<LogName>.*?) (?<User>.*?) \[(?<TimeString>.*?)\] `"(?<Request>.*?)`" (?<Status>.*?) (?<BytesSent>.*?) `"(?<Referer>.*?)`" `"(?<UserAgent>.*?)`"$") {
          throw "Invalid line: $_"
       }
       
       $entry = $matches
       $entry.Time = [DateTime]::ParseExact($entry.TimeString, "dd/MMM/yyyy:HH:mm:ss zzz", [System.Globalization.CultureInfo]::InvariantCulture)
       if ($entry.Request -match "^(?<Method>.*?) (?<Path>.*?) (?<Version>.*)$") {
          $entry.Method = $matches.Method
          $entry.Path = $matches.Path
          $entry.Version = $matches.Version
       }
       
       return New-Object PSObject -Property $entry
    }
}