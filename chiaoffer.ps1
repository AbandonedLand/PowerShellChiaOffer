Class ChiaOffer{
    [hashtable]$offer
    $coins
    $fee
    $offertext
    $json
    $dexie_response
    $dexie_url 
    $requested_nft_data
    $nft_info
    $max_height
    $max_time
    $validate_only
    $bulk_nft_info

    ChiaOffer(){
        $this.max_height = 0
        $this.max_time = 0
        $this.fee = 0
        $this.offer = @{}
        $this.validate_only = $false
        $this.dexie_url = "https://dexie.space/v1/offers"
    }

    offerednft($nft_id){
        $this.RPCNFTInfo($nft_id)
        $this.offer.($this.nft_info.launcher_id.substring(2))=-1
    }

    requestednft($nft_id){
        $this.RPCNFTInfo($nft_id)
        $this.offer.($this.nft_info.launcher_id.substring(2))=1
        $this.BuildDriverDict($this.nft_info)
    }

    requested([string]$wallet_id, $amount){
        if($wallet_id.ToLower() -eq "xch"){
            $this.offer."1"=([int64]($amount*1000000000000))
        } else {
            $this.offer."$wallet_id"=($amount*1000)
        }
    }

    expiresInBlocks($num){

        $this.max_height = (((chia rpc wallet get_height_info) | convertfrom-json).height) + $num
    }

    setMaxHeight($num){
        $this.max_height = $num
    }
    

    expiresIn($min){
        $DateTime = (Get-Date).ToUniversalTime()
        $DateTime = $DateTime.AddMinutes($min)
        $this.max_time = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
    }

    requestxch($amount){
        
        $this.offer."1"=([int64]($amount*1000000000000))
        
    }
 

    offerxch($amount){
        
        $this.offer."1"=([int64]($amount*-1000000000000))
        
    }

    offered([string]$wallet_id, $amount){
        if($wallet_id.ToLower() -eq "xch"){
            $this.offer."1"=([int64]($amount*-1000000000000))
        } else {
            $this.offer."$wallet_id"=([int64]($amount*-1000))
        }
    }

    validateonly(){
        $this.validate_only = $true
    }

    dontlock(){    
        $this.validate_only = $true
    }
    
    makejson(){
        if($this.max_time -ne 0){
            $this.json = (
                [ordered]@{
                    "offer"=($this.offer)
                    "fee"=$this.fee
                    "validate_only"=$this.validate_only
                    "reuse_puzhash"=$true
                    "driver_dict"=$this.requested_nft_data
                    "max_time"=$this.max_time
                } | convertto-json -Depth 11)        
        } elseif($this.max_height -ne 0){
            $this.json = (
                [ordered]@{
                    "offer"=($this.offer)
                    "fee"=$this.fee
                    "validate_only"=$this.validate_only
                    "reuse_puzhash"=$true
                    "driver_dict"=$this.requested_nft_data
                    "max_height"=$this.max_height
                } | convertto-json -Depth 11)        
        } else {
            $this.json = (
                [ordered]@{
                    "offer"=($this.offer)
                    "fee"=$this.fee
                    "validate_only"=$this.validate_only
                    "reuse_puzhash"=$true
                    "driver_dict"=$this.requested_nft_data
                } | convertto-json -Depth 11)     
        } 
    } 
    


    createoffer(){
        $this.makejson()
        try{
            $this.offertext = chia rpc wallet create_offer_for_ids $this.json
        } catch {
            Write-Error "Unable to create offer"
        }
        
    }

    createofferwithoutjson(){
        $this.offertext = chia rpc wallet create_offer_for_ids $this.json
    }
    

    postToDexie(){
        if($this.offertext){
            $data = $this.offertext | convertfrom-json
            $body = @{
                "offer" = $data.offer
                "claim_rewards" = $true
            }
            $contentType = 'application/json' 
            $json_offer = $body | convertto-json
            $this.dexie_response = Invoke-WebRequest -Method POST -body $json_offer -Uri $this.dexie_url -ContentType $contentType
        } else {
            Write-Error "No offer available to post to dexie."
        }
        
    }
    

    RPCNFTInfo($nft_id){
        $this.nft_info = (chia rpc wallet nft_get_info ([ordered]@{coin_id=$nft_id} | ConvertTo-Json) | Convertfrom-json).nft_info
    }

    BuildDriverDict($data){
    
        $this.requested_nft_data = [ordered]@{($data.launcher_id.substring(2))=[ordered]@{
                type='singleton';
                launcher_id=$data.launcher_id;
                launcher_ph=$data.launcher_puzhash;
                also=[ordered]@{
                    type='metadata';
                    metadata=$data.chain_info;
                    updater_hash=$data.updater_puzhash;
                    also=[ordered]@{
                        type='ownership';
                        owner=$data.owner_did;
                        transfer_program=[ordered]@{
                            type='royalty transfer program';
                            launcher_id=$data.launcher_id;
                            royalty_address=$data.royalty_puzzle_hash;
                            royalty_percentage=[string]$data.royalty_percentage
                        }
                    }
                }
            }
        }
        
    }


}

