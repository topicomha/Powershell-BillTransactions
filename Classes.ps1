class BankTransaction {
    [int]$ID
    [string]$Direction
    [Datetime] $PostingDate
    [string]$Description
    [float]$Amount
    [string]$Type
    [float]$Balance
    [string]$CheckOrSlipNumber
}
class DebitTransaction {
    [int]$ID
    [int]$OGID
    [int]$CreditID
    [datetime]$PostingDate
    [string]$Description
    [float]$Amount
    [string]$Type
    [float]$Balance
    [string]$CheckOrSlipNumber
    [string]$AsscoiatedPerson
    [string]$BillType
}
class CreditTransaction {
    [int]$ID
    [int]$OGID
    [datetime]$PostingDate
    [string]$Description
    [float]$Amount
    [string]$Type
    [float]$Balance
    [string]$CheckOrSlipNumber
    [string]$AsscoiatedPerson
    [string]$BillType
}

class BillReportItem {
    [int]$ID
    [Nullable[DateTime]]$BillDate
    [Nullable[DateTime]]$PaymentDate
    [string]$BillDescription
    [string]$PaymentDescription
    [Nullable[float]]$BillAmount
    [Nullable[float]]$PaymentAmount
    [string]$AsscoiatedPerson
    [string]$BillType
}

