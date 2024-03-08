#####################################################
# debugStart
# PowerShell V2
#####################################################

# The 'CustomList' is a wrapper class around '[System.Collections.Generic.List].
# Its being used in the 'outputContext.AuditLogs'. 
# When a new auditLog is added, the message will be automatically displayed within the VSCode UI.
class CustomList {
    $list = [System.Collections.Generic.List[object]]::new()
    [void] Add([object] $obj) {
        $this.list.Add($obj)
        $scriptBlock = {
            if ($obj.IsError){
                $psEditor.Window.ShowErrorMessage("Message: [$($obj.Message)]. Action: [$($obj.Action)]")
            } else {
                $psEditor.Window.ShowInformationMessage("Message: [$($obj.Message)]. Action: [$($obj.Action)]")
            }
        }
        $method = [ScriptBlock]::Create($scriptBlock)
        $method.Invoke()
    }
}

# Import person and fieldMapping
$person = Get-content '{folderPath}/demoPerson.json' | ConvertFrom-Json
$fieldMapping = Get-Content '{folderPath}/fieldMapping.json' | ConvertFrom-Json

# Define the context variables. Note that the variables are not used. 
# They need to be 'initiliazed'. Values will be assigned to them
# whenever a lifecycle action is being executed.
$actionContext = @{
    Configuration = $config
    DryRun        = $false
    Operation     = 'undefined'
    Data          = @{}
    CorrelationConfiguration = @{
        Enabled           = $true
        PersonField       = $null
        PersonFieldValue  = $null
        AccountField      = $null
        AccountFieldValue = $null
    }
    AccountCorrelated = $true
    References = @{
        Account        = ''
        ManagerAccount = ''
    }
}

$personContext = @{Person = $person}

$outputContext = @{
    Data              = $null
    AuditLogs         = [CustomList]::new()
    AccountReference  = $null
    Success           = $null
    AccountCorrelated = $false
}

# Add fields from fieldMapping to actionContext.Data
foreach ($field in $fieldMapping.MappingFields){
    $trimmedValue = $field.MappingActions[0].Value.Trim('"')
    if ($field.Name.Contains('.')) {
        $keys = $field.Name.Split('.')
        $propertyName = $keys[0]
        $nestedPropertyName = $keys[1]
        if (-not $actionContext.Data.ContainsKey($propertyName)) {
            $actionContext.Data[$propertyName] = @{}
        }
        $actionContext.Data[$propertyName][$nestedPropertyName] = "`$$trimmedValue" 
    } elseif ($field.MappingActions[0].MappingMode -eq 'Field'){
        $trimmedValue = $field.MappingActions[0].Value.Trim('"')
        $actionContext.Data[$field.Name] = "`$$trimmedValue"
    } elseif ($field.MappingActions[0].MappingMode -eq 'Fixed'){
        $actionContext.Data[$field.Name] = $field.MappingActions[0].Value
    } elseif ($field.MappingActions[0].MappingMode -eq 'Complex'){
        $actionContext.Data[$field.Name] = 'ComplexMapping'
    }
}