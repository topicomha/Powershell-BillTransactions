. "$PSScriptRoot\Classes.ps1"

# Import the configuration file
$moduleConfig = Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath 'JointAccountHelperModuleConfig.ps1')


# Define the module functions
function Compare-TransactionsFromBankAccountCSV {
    [CmdletBinding()]
    param (
        [string]$Path
    )

    begin {
        write-verbose "Config: $($moduleConfig.BankAccountCSVPath)"
        write-verbose "Path: $Path"
        if ($Path -eq $null -or $Path -eq '') {
            write-verbose "Path is null, using default path from config: $($moduleConfig.BankAccountCSVPath)"
            $Path = Join-Path -Path $PSScriptRoot -ChildPath $moduleConfig.BankAccountCSVPath
        }
        write-verbose "Path: $Path"
    }

    process {
        write-verbose "Config: $moduleConfig"
        write-verbose "Path: $Path"

        $csvData = Import-Csv -Path $Path

        Write-Verbose "CSV rows: $($csvData.Count)"

        # Save CSV data in a list of bank transactions
        $ogID = 1
        $DebitID = 1
        $CreditID = 1
        $BillReportID = 1

        $bankTransactions = @()
        $debitTransactions = @()
        $creditTransactions = @()
        $BillReport = @()

        foreach ($row in $csvData) {
            Write-Verbose "Row: $row"
            $bankTransaction = [BankTransaction]::new()
            $bankTransaction.ID = $ogID++
            $bankTransaction.Direction = $row.Details
            $bankTransaction.PostingDate = $row."Posting Date"
            $bankTransaction.Description = $row.Description
            $bankTransaction.Amount = $row.Amount
            $bankTransaction.Type = $row.Type
            $bankTransaction.Balance = $row.Balance
            $bankTransaction.CheckOrSlipNumber = $row."Check Or Slip #"

            $bankTransactions += $bankTransaction

            $AsscoiatedPerson = Get-Person -Description $row.Description
            Write-Verbose "AsscoiatedPerson: $AsscoiatedPerson for Description: $($row.Description)"
            
            $BillType = Get-BillType -Description $row.Description
            Write-Verbose "BillType: $BillType for Description: $($row.Description)"
            
            if ($AsscoiatedPerson -eq "Rent") {
                $debitTransaction1 = [DebitTransaction]::new()
                $debitTransaction1.ID = $DebitID++
                $debitTransaction1.OGID = $bankTransaction.ID
                $debitTransaction1.PostingDate = $row."Posting Date"
                $debitTransaction1.Description = $row.Description + "- Split"
                $debitTransaction1.Amount = [Math]::Abs($row.Amount) / 2
                $debitTransaction1.Type = $row.Type
                $debitTransaction1.Balance = $row.Balance
                $debitTransaction1.CheckOrSlipNumber = $row."Check Or Slip #"
                $debitTransaction1.AsscoiatedPerson = "David"
                $debitTransaction1.BillType = $BillType

                $debitTransactions += $debitTransaction1

                write-verbose "Added Debit Transaction: 
                    ID: $($debitTransaction1.ID) 
                    OGID: $($debitTransaction1.OGID) 
                    Amount: $($debitTransaction1.Amount) 
                    Balance: $($debitTransaction1.Balance) 
                    Description: $($debitTransaction1.Description) 
                    CheckOrSlipNumber: $($debitTransaction1.CheckOrSlipNumber) 
                    Type: $($debitTransaction1.Type) 
                    PostingDate: $($debitTransaction1.PostingDate) 
                    Asscoiated Person: $($debitTransaction1.AsscoiatedPerson)
                    BillType: $($debitTransaction1.BillType)"
                
                $debitTransaction2 = [DebitTransaction]::new()
                $debitTransaction2.ID = $DebitID++
                $debitTransaction2.OGID = $bankTransaction.ID
                $debitTransaction2.PostingDate = $row."Posting Date"
                $debitTransaction2.Description = $row.Description + "- Split"
                $debitTransaction2.Amount = [Math]::Abs($row.Amount) / 2
                $debitTransaction2.Type = $row.Type
                $debitTransaction2.Balance = $row.Balance
                $debitTransaction2.CheckOrSlipNumber = $row."Check Or Slip #"
                $debitTransaction2.AsscoiatedPerson = "Jennifer"
                $debitTransaction2.BillType = $BillType
                
                $debitTransactions += $debitTransaction2
                
                write-verbose "Added Debit Transaction: 
                    ID: $($debitTransaction2.ID) 
                    OGID: $($debitTransaction2.OGID) 
                    Amount: $($debitTransaction2.Amount) 
                    Balance: $($debitTransaction2.Balance) 
                    Description: $($debitTransaction2.Description) 
                    CheckOrSlipNumber: $($debitTransaction2.CheckOrSlipNumber) 
                    Type: $($debitTransaction2.Type) 
                    PostingDate: $($debitTransaction2.PostingDate) 
                    Asscoiated Person: $($debitTransaction2.AsscoiatedPerson)
                    BillType: $($debitTransaction2.BillType)"
            }
            else {
                if ($row.Details -eq "DEBIT") {
                    $debitTransaction = [DebitTransaction]::new()
                    $debitTransaction.ID = $DebitID++
                    $debitTransaction.OGID = $bankTransaction.ID
                    $debitTransaction.PostingDate = $row."Posting Date"
                    $debitTransaction.Description = $row.Description
                    $debitTransaction.Amount = [Math]::Abs($row.Amount)
                    $debitTransaction.Type = $row.Type
                    $debitTransaction.Balance = $row.Balance
                    $debitTransaction.CheckOrSlipNumber = $row."Check Or Slip #"
                    $debitTransaction.AsscoiatedPerson = $AsscoiatedPerson
                    $debitTransaction.BillType = $BillType

                    $debitTransactions += $debitTransaction
                
                    write-verbose "Added Debit Transaction: 
                    ID: $($debitTransaction.ID) 
                    OGID: $($debitTransaction.OGID) 
                    Amount: $($debitTransaction.Amount) 
                    Balance: $($debitTransaction.Balance) 
                    Description: $($debitTransaction.Description) 
                    CheckOrSlipNumber: $($debitTransaction.CheckOrSlipNumber) 
                    Type: $($debitTransaction.Type) 
                    PostingDate: $($debitTransaction.PostingDate) 
                    Asscoiated Person: $($debitTransaction.AsscoiatedPerson)
                    BillType: $($debitTransaction.BillType)"
                }
                else {
                
                    $creditTransaction = [CreditTransaction]::new()
                    $creditTransaction.ID = $CreditID++
                    $creditTransaction.OGID = $bankTransaction.ID
                    $creditTransaction.PostingDate = $row."Posting Date"
                    $creditTransaction.Description = $row.Description
                    $creditTransaction.Amount = $row.Amount
                    $creditTransaction.Type = $row.Type
                    $creditTransaction.Balance = $row.Balance
                    $creditTransaction.CheckOrSlipNumber = $row."Check Or Slip #"
                    $creditTransaction.AsscoiatedPerson = $AsscoiatedPerson

                    $creditTransactions += $creditTransaction
                    write-verbose "Added Credit Transaction: 
                    ID: $($creditTransaction.ID) 
                    OGID: $($creditTransaction.OGID) 
                    Amount: $($creditTransaction.Amount) 
                    Balance: $($creditTransaction.Balance) 
                    Description: $($creditTransaction.Description) 
                    CheckOrSlipNumber: $($creditTransaction.CheckOrSlipNumber) 
                    Type: $($creditTransaction.Type) 
                    PostingDate: $($creditTransaction.PostingDate)
                    Asscoiated Person: $($creditTransaction.AsscoiatedPerson)" 
                }
            }
        }
        
        # Save $creditTransactions to a CSV files
        $creditTransactionsCSVPath = Join-Path -Path $PSScriptRoot -ChildPath "CreditTransactions.csv"
        $creditTransactions | Export-CSV -Path $creditTransactionsCSVPath
        
        #Save $bankTransactions to a CSV file
        $bankTransactionsCSVPath = Join-Path -Path $PSScriptRoot -ChildPath "BankTransactions.csv"
        $bankTransactions | Export-CSV -Path $bankTransactionsCSVPath
        
        $MactchedIDs = @()
        #Match Debit and Credit Transactions

        foreach ($debitTran in $debitTransactions) {
            #Create BillReport Item and fill in the debit transaction
            $BillReportItem = [BillReportItem]::new()
            $BillReportItem.ID = $BillReportID++
            $BillReportItem.BillAmount = $debitTran.Amount
            $BillReportItem.BillDescription = $debitTran.Description
            $BillReportItem.BillDate = $debitTran.PostingDate.Date
            $BillReportItem.BillType = $debitTran.BillType
            $BillReportItem.AsscoiatedPerson = $debitTran.AsscoiatedPerson

            Write-Verbose "Matching Debit Transaction:  
                ID: $($debitTran.ID) 
                OGID: $($debitTran.OGID)  
                Amount: $($debitTran.Amount)  
                Balance: $($debitTran.Balance)  
                Description: $($debitTran.Description)  
                CheckOrSlipNumber: $($debitTran.CheckOrSlipNumber) 
                Type: $($debitTran.Type) 
                PostingDate: $($debitTran.PostingDate.Date) 
                Asscoiated Person: $($debitTran.AsscoiatedPerson)"
            
            #Look for a credit transaction with the same amount and assosiated person
            $foundTrans = $creditTransactions | Where-Object { $_.Amount -eq $debitTran.Amount -and $_.AsscoiatedPerson -eq $debitTran.AsscoiatedPerson -and $_.ID -notin $MactchedIDs }
            if ($foundTrans -eq $null) {
                $BillReportItem.PaymentAmount = $null
                $BillReportItem.PaymentDescription = $null
                $BillReportItem.PaymentDate = $null
                $BillReport += $BillReportItem
                continue  
            }

            if ($foundTrans.Count -gt 1) {
                #Find the credit transaction with the closest posting date to the debit transaction
                $closestItem = $foundTrans[0]
                $closestDifference = [Math]::Abs(($closestItem.Date - $targetDate).TotalSeconds)

                foreach ($item in $foundTrans) {
                    $difference = [Math]::Abs(($item.Date - $targetDate).TotalSeconds)
                    if ($difference -lt $closestDifference) {
                        $closestItem = $item
                        $closestDifference = $difference
                    }
                }
                $foundTrans = $closestItem
            }

            Write-Host "Found ID: $($foundTrans.ID) in Credit Transactions: 
                OGID: $($foundTrans.OGID) 
                Amount: $($foundTrans.Amount) 
                Balance: $($foundTrans.Balance) 
                Description: $($foundTrans.Description) 
                CheckOrSlipNumber: $($foundTrans.CheckOrSlipNumber) 
                Type: $($foundTrans.Type)
                PostingDate: $($foundTrans.PostingDate.Date)
                Asscoiated Person: $($foundTrans.AsscoiatedPerson)"

            $debitTran.CreditID = $foundTrans.ID
            
            $MactchedIDs += $foundTrans.ID
            
            $BillReportItem.PaymentAmount = $foundTrans.Amount
            $BillReportItem.PaymentDescription = $foundTrans.Description
            $BillReportItem.PaymentDate = $foundTrans.PostingDate.Date
            
            $BillReport += $BillReportItem
        }
        # Add the rest of the credit transactions to the bill report
        $notfound = $creditTransactions | Where-Object { $_.ID -notin $MactchedIDs }

        foreach ($tran in $notfound) {
            $BillReportItem = [BillReportItem]::new()
            $BillReportItem.ID = $BillReportID++
            $BillReportItem.PaymentAmount = $tran.Amount
            $BillReportItem.PaymentDescription = $tran.Description
            $BillReportItem.PaymentDate = $tran.PostingDate.Date
            $BillReportItem.BillType = $tran.BillType
            $BillReportItem.AsscoiatedPerson = $tran.AsscoiatedPerson
            
            $BillReport += $BillReportItem
        }

        
        # Save $depositTransactions to a CSV files
        $debitTransactionsCSVPath = Join-Path -Path $PSScriptRoot -ChildPath "DebitTransactions.csv"
        $debitTransactions | Export-CSV -Path $debitTransactionsCSVPath

        
        # Save $BillReport to a CSV files
        $BillReportCSVPath = Join-Path -Path $PSScriptRoot -ChildPath "BillReport.csv"
        $BillReport | Export-CSV -Path $BillReportCSVPath
        
        return $BillReport
    }
}

function Get-Person {
    [CmdletBinding()]
    param (
        [string]$Description
    )
    Write-Verbose "Looking for Person by Description: $Description"

    $DavidsCheckingAccountPattern = "Online Transfer from\s+CHK\s+?...9196"
    if ($Description -match $DavidsCheckingAccountPattern) {
        Write-Verbose "Matched ""$DavidsCheckingAccountPattern"""
        return "David"
    }
    
    $JensCheckingAccountPattern = "Online Transfer from\s+CHK\s+?...3011|Online Transfer from\s+CHK\s+?...6972"
    if ($Description -match $JensCheckingAccountPattern) {
        Write-Verbose "Matched ""$JensCheckingAccountPattern"""
        return "Jennifer"
    }

    $DavidsBillPayPattern = "IRVINE RANC|LANDSCAPE|SO CAL GAS|WASTE MANAGEMENT|MONTHLY SERVICE FEE"
    if ($Description -match $DavidsBillPayPattern) {
        Write-Verbose "Matched ""$DavidsBillPayPattern"""
        return "David"
    }

    $JensBillPayPattern = "SO CAL EDISON|COX COMM ORG"
    if ($Description -match $JensBillPayPattern) {
        Write-Verbose "Matched ""$JensBillPayPattern"""
        return "Jennifer"
    }
    
    
    $RentBillPayPattern = "Jingqiu Xie"
    if ($Description -match $RentBillPayPattern) {
        Write-Verbose "Matched ""$RentBillPayPattern"""
        return "Rent"
    }

    write-verbose "No match found for Description: $Description"
    return "Unknown"
}

function Get-BillType {
    [CmdletBinding()]
    param (
        [string]$Description
    )
    Write-Verbose "Looking for Bill Type by Description: $Description"

    $WaterBill = "IRVINE RANC"
    if ($Description -match $WaterBill) {
        Write-Verbose "Matched ""$WaterBill"""
        return "Water Bill"
    }

    $ElectricityBill = "SO CAL EDISON"
    if ($Description -match $ElectricityBill) {
        Write-Verbose "Matched ""$ElectricityBill"""
        return "Electricity Bill"
    }

    $GasBill = "SO CAL GAS"
    if ($Description -match $GasBill) {
        Write-Verbose "Matched ""$GasBill"""
        return "Gas Bill"
    }

    $CableBill = "COX COMM ORG" 
    if ($Description -match $CableBill) {
        Write-Verbose "Matched ""$CableBill"""
        return "Cable Bill"
    }

    $TrashBill = "WASTE MANAGEMENT"
    if ($Description -match $TrashBill) {
        Write-Verbose "Matched ""$TrashBill"""
        return "Trash Bill"
    }

    $LandscapeBill = "LANDSCAPE"
    if ($Description -match $LandscapeBill) {
        Write-Verbose "Matched ""$LandscapeBill"""
        return "Landscape Bill"
    }

    $RentBill = "Jingqiu Xie"
    if ($Description -match $RentBill) {
        Write-Verbose "Matched ""$RentBill"""
        return "Rent Bill"
    }

    
    write-verbose "No match found for Description: $Description"
    return "Unknown"
}


