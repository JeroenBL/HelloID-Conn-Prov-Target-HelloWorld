#################################################
# HelloID-Conn-Prov-Target-HelloWorld-Create
# PowerShell V2
#################################################

try {
    Write-Verbose "Correlating HelloWorld account for: [$($personContext.Person.DisplayName)]"
    $correlatedAccount = @{
        id          = '1'
        displayName = $actionContext.Data.DisplayName
        ExternalId  = $actionContext.Data.ExternalId
    }

    $outputContext.Data = $correlatedAccount
    $outputContext.AccountReference = $correlatedAccount.id
    $outputContext.AccountCorrelated = $true
    $outputContext.success = $true
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Action  = 'CorrelateAccount'
            Message = "Correlated account for: [$($personContext.Person.DisplayName)] with message: Hello World"
            IsError = $false
        })
} catch {
    $outputContext.success = $false
    $auditMessage = "Could not $action HelloWorld account. Error: $($_.Exception.Message)"
    Write-Warning "Error at Line '$($_.InvocationInfo.ScriptLineNumber)': $($_.InvocationInfo.Line). Error: $($_.Exception.Message)"
    $outputContext.AuditLogs.Add([PSCustomObject]@{
            Message = $auditMessage
            IsError = $true
        })
}