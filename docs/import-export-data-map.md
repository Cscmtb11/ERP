# Import/Export ERP Data Map

Mapped from `SmanSayeed/Import-Export-Company-ERP`.

## Core entities

### Bank
- bankname
- bankaccount
- bankbranch
- bankswift

### Customer / Importer
- companyname
- contactperson
- branch
- address
- contactno
- swift
- email
- contactemail
- phone
- importerbank

### Sales / Export Contract
- contract identity: name, salescontractno, dateofcontractregistration
- parties: beneficiarybank, importer, notify-party fields
- shipment: shipmentform, shipmentdestination, modeoftransport, lastdateofshipment
- commercial terms: currency, advancepayment, partadvancepayment, modeofpayment, methodofpayment
- trade/LC references: iban, expno, lcl, lcno
- product: nameoftheproduct, productcode, productdescription
- logistics quantities: quantitypcs, ctns, price, netweight, totalnetweightcgs, grossweight, totalgrossweightcgs
- controls: partshipment, transshipment, productofshipment, percentegeofproductofshipment
