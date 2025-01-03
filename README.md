# PowerShell Chia Offer Class
 PowerShell Class for creating Chia Offers

## Prerequisets
[PowerShell 7.4+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.4): This can be installed on any OS, not just windows.  

Chia Reference Wallet with chia.exe in your environment variable.  
Please review [CLI Reference](https://docs.chia.net/cli/) for help setting your environment varialbes for chia. 

## How to use
Dot reference the powershell file in your script.
```powershell
# Put at head of file.
. ./chiaoffer.ps1
```

# Examples

### Buying 300 DBX for 1 XCH
```powershell
# dbx asset_id = db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20

# Create an offer object
$offer = [ChiaOffer]::new();

# Request 300 dbx
# $offer.requested([asset_id],[amount])

$offer.requested("db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20", 300)

# Offer 1 xch 
# $offer.offered([asset_id],[amount])

$offer.offered("xch",1)

# Generate the offer in the chia reference wallet

$offer.createoffer()

# Upload the offer to dexie

$offer.postToDexie()
```

### Selling 1 xch for 25 wUSDC.b that expires
> [!NOTE] 
> There are about 3 blocks per minute.

```PowerShell
# wUSDC.b asset_id = fa4a180ac326e67ea289b869e3448256f6af05721f7cf934cb9901baa6b7a99d

$offer = [ChiaOffer]::new()
$offer.offered('xch',1)
$offer.requested('fa4a180ac326e67ea289b869e3448256f6af05721f7cf934cb9901baa6b7a99d',25)


# --------------------------------
# Choose to expire in minutes
# OR in maximum blocks.
# --------------------------------

# Add experation in minutes
$offer.expiresInMinutes(10)
# Expires in 10 min from now

# Add experation in blocks 
$offer.expiresInBlocks(30)
# Expires in 30 blocks from now

# --------------------------------


$offer.createoffer()
$offer.postToDexie()

```

### Request multiple tokens at once - 200 dbx and 15 wUSDC.b for 1 xch

```PowerShell

$offer = [ChiaOffer]::new()
$offer.offered('xch',1)
# You can string together multiple Requested or Offered tokens.
$offer.requested('fa4a180ac326e67ea289b869e3448256f6af05721f7cf934cb9901baa6b7a99d',15)
$offer.requested("db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20", 200)
$offer.createoffer()
$offer.postToDexie()
```

### Buy an NFT for 0.1 XCH
```PowerShell
$offer = [ChiaOffer]::new()
$offer.offered('xch',0.1)
$offer.requestednft("nft1lctja2m508pzdtrjl2kckhyd5s6tktxgv4cpdrtqa5x3zd3wt96stgz9c0")
$offer.createoffer()
$offer.postToDexie()
```

### Sell an NFT for 0.5 XCH
```PowerShell
$offer = [ChiaOffer]::new()
$offer.requested('xch',0.5)
$offer.offerednft("nft1lctja2m508pzdtrjl2kckhyd5s6tktxgv4cpdrtqa5x3zd3wt96stgz9c0")
$offer.createoffer()
$offer.postToDexie()
```

### Create offer WITHOUT locking up the coins
> [!WARNING]
> The Wallet will not properly track this offer.  It will not show up in your offers list.  It can only be cancelded by sending that coin back to yourself. I would recommend making these types of offers expire.
```PowerShell

$offer = [ChiaOffer]::new()
$offer.offered('xch',1)
$offer.requested('fa4a180ac326e67ea289b869e3448256f6af05721f7cf934cb9901baa6b7a99d',25)

# Adding dontlock() before creating an offer will make
# your wallet not track this offer.  

$offer.dontlock()
$offer.expiresInMinutes(10)



$offer.createoffer()
$offer.postToDexie()

```

### Offer 1 NFT for another
```PowerShell
$offer = [ChiaOffer]::new()
$offer.requestednft('nft1j57kfn3fl0a6hzxqrg9jlv0xx5x4dwkuc3jfkq4gsek3ry8yyruqm3c549')
$offer.offerednft("nft1lctja2m508pzdtrjl2kckhyd5s6tktxgv4cpdrtqa5x3zd3wt96stgz9c0")
$offer.createoffer()
$offer.postToDexie()
```