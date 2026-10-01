-- Import/Export ERP domain schema and demo data
-- Source: SmanSayeed/Import-Export-Company-ERP
-- Target: Cscmtb11/ERP

CREATE TABLE IF NOT EXISTS bankmodels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  bankname VARCHAR(100) NULL,
  bankaccount VARCHAR(100) NULL,
  bankbranch VARCHAR(100) NULL,
  bankswift VARCHAR(100) NULL,
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

INSERT INTO bankmodels (id, bankname, bankaccount, bankbranch, bankswift, created_at, updated_at)
VALUES
(1,'city bank','aa333','dhaka','2sad','2019-08-19 19:42:06','2019-08-19 19:42:06'),
(2,'dbbl','saa3333','comilla','fsadf','2019-08-19 19:42:19','2019-08-19 19:42:19')
ON DUPLICATE KEY UPDATE
bankname=VALUES(bankname), bankaccount=VALUES(bankaccount), bankbranch=VALUES(bankbranch),
bankswift=VALUES(bankswift), updated_at=VALUES(updated_at);

CREATE TABLE IF NOT EXISTS customermodels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  companyname VARCHAR(100) NULL,
  contactperson VARCHAR(100) NULL,
  branch VARCHAR(100) NULL,
  address VARCHAR(100) NULL,
  contactno VARCHAR(100) NULL,
  swift VARCHAR(100) NULL,
  email VARCHAR(100) NULL,
  contactemail VARCHAR(100) NULL,
  phone VARCHAR(100) NULL,
  importerbank VARCHAR(100) NULL,
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

INSERT INTO customermodels
(id,companyname,contactperson,branch,address,contactno,swift,email,contactemail,phone,importerbank,created_at,updated_at)
VALUES
(1,'Mensa','Arko','Comilla','fads','fadsf','adsf','fdsa','fas','fadsf','adsf','2019-08-19 19:42:44','2019-08-19 19:42:44'),
(2,'Vuu','Saad','sdfa','dsf','dsf','sadf','fasdf','dsaf','adsf','fadsf','2019-08-19 19:42:56','2019-08-19 19:42:56')
ON DUPLICATE KEY UPDATE
companyname=VALUES(companyname), contactperson=VALUES(contactperson), branch=VALUES(branch),
address=VALUES(address), contactno=VALUES(contactno), swift=VALUES(swift), email=VALUES(email),
contactemail=VALUES(contactemail), phone=VALUES(phone), importerbank=VALUES(importerbank),
updated_at=VALUES(updated_at);

CREATE TABLE IF NOT EXISTS salesmodels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NULL,
  beneficiarybank VARCHAR(100) NULL,
  beneficiarybank_id VARCHAR(191) NULL,
  importer VARCHAR(191) NULL,
  importer_id VARCHAR(191) NULL,
  salescontractno VARCHAR(100) NULL,
  dateofcontractregistration VARCHAR(100) NULL,
  notifyparty VARCHAR(100) NULL,
  notifypartycheck VARCHAR(191) NULL,
  othernotifyparty VARCHAR(100) NULL,
  shipmentform VARCHAR(100) NULL,
  shipmentdestination VARCHAR(100) NULL,
  nameoftheproduct VARCHAR(100) NULL,
  lastdateofshipment VARCHAR(100) NULL,
  contractvalidupto VARCHAR(100) NULL,
  packingofbags VARCHAR(100) NULL,
  partshipment VARCHAR(100) NULL,
  modeoftransport VARCHAR(100) NULL,
  modeofpayment VARCHAR(100) NULL,
  methodofpayment VARCHAR(100) NULL,
  currency VARCHAR(100) NULL,
  advancepayment DOUBLE NULL,
  partadvancepayment VARCHAR(100) NULL,
  transshipment VARCHAR(100) NULL,
  productofshipment VARCHAR(100) NULL,
  percentegeofproductofshipment DOUBLE NULL,
  iban VARCHAR(100) NULL,
  expno VARCHAR(100) NULL,
  lcl VARCHAR(100) NULL,
  lcno VARCHAR(100) NULL,
  sales_pro_key INT NOT NULL DEFAULT 0,
  productcode VARCHAR(100) NULL,
  quantitypcs DOUBLE NULL,
  ctns DOUBLE NULL,
  price DOUBLE NULL,
  netweight DOUBLE NULL,
  totalnetweightcgs DOUBLE NULL,
  grossweight DOUBLE NULL,
  totalgrossweightcgs DOUBLE NULL,
  productdescription TEXT NULL,
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id)
);

INSERT INTO salesmodels
(id,name,beneficiarybank,importer,salescontractno,dateofcontractregistration,shipmentform,shipmentdestination,nameoftheproduct,lastdateofshipment,contractvalidupto,packingofbags,partshipment,modeoftransport,modeofpayment,methodofpayment,currency,advancepayment,partadvancepayment,transshipment,productofshipment,percentegeofproductofshipment,iban,expno,lcl,lcno,productcode,quantitypcs,ctns,price,netweight,totalnetweightcgs,grossweight,totalgrossweightcgs,productdescription,created_at,updated_at)
VALUES
(1,'saad','dbbl','Vuu Saad','27','2019-08-22','Bld Mihail Kogalniceanu22, nr. 8 Bl 1, Sc 1, Ap 09','Bld Mihail Kogalniceanu, 22nr. 8 Bl 1, Sc 1, Ap 09','suger22','2019-08-27','2019-08-05','22','Allowed','By Road','TT','FOB','on',22.00,'Allowed','Allowed','Allowed',22.00,'22','22','22','22','22',22.00,22.00,222.00,22.00,22.00,22.00,22.00,'22','2019-08-19 19:48:14','2019-08-19 20:12:35'),
(2,'Jessica Jones4324','dbbl','Vuu Saad','274324','2019-08-16','Bld Mihail Kogalniceanu, n4324r. 8 Bl 1, Sc 1, Ap 09','Bld Mihail Kogalniceanu, nr324. 8 Bl 1, Sc 1, Ap 09','suger324','2019-08-13','2019-07-31','43242','Allowed','By Road','TT','FOB','on',23423.00,'Allowed','Allowed','Allowed',4234.00,'4324','324','4324','324','324',324.00,4324.00,234.00,423.00,432.00,4234.00,24.00,'324','2019-08-19 19:49:26','2019-08-19 19:49:26')
ON DUPLICATE KEY UPDATE
name=VALUES(name), beneficiarybank=VALUES(beneficiarybank), importer=VALUES(importer),
salescontractno=VALUES(salescontractno), dateofcontractregistration=VALUES(dateofcontractregistration),
shipmentform=VALUES(shipmentform), shipmentdestination=VALUES(shipmentdestination),
nameoftheproduct=VALUES(nameoftheproduct), lastdateofshipment=VALUES(lastdateofshipment),
contractvalidupto=VALUES(contractvalidupto), packingofbags=VALUES(packingofbags),
partshipment=VALUES(partshipment), modeoftransport=VALUES(modeoftransport),
modeofpayment=VALUES(modeofpayment), methodofpayment=VALUES(methodofpayment),
currency=VALUES(currency), advancepayment=VALUES(advancepayment),
productdescription=VALUES(productdescription), updated_at=VALUES(updated_at);
