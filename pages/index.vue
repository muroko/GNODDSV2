<template>
  <div class="flex flex-col mx-[10%] md:mx-[64px] mt-[30px] md:mt-[123px]">
    <h2 class="text-[30px] text-[#D5D83D] ml-[3px]">Protocol Stats</h2>
    <div class="md:flex flex-wrap gap-[24px] mt-[32px]">
      <DataTable
      v-for="(item, i) in protocolStats"
        :key="i"
        :title="item.title"
        :icon="item.icon"
        :price="item.price"
        :percentage="item.percentage"/>
    </div>
    <h2 class="text-[30px] text-[#D5D83D] ml-[3px] mt-[30px] md:mt-[118px]">Personal Stats</h2>
    <div class="md:flex flex-wrap gap-[24px] mt-[32px]">
      <DataTable
      v-for="(item, i) in personalStats"
        :key="i"
        :title="item.title"
        :icon="item.icon"
        :price="item.price"
        :percentage="item.percentage"/>
    </div>
    </div>
  </div>
</template>

<script lang="ts">
import { mapGetters } from "vuex";
import { Component, Prop, Vue } from 'nuxt-property-decorator'

import axios from "axios"

import { abi as NODER } from "~/gem-contract/artifacts/contracts/NODERewardManager.sol/NODERewardManager.json";
import { abi as GEM } from "~/gem-contract/artifacts/contracts/GemNodesV2.sol/GemNodesV2.json";

import {WalletModule} from '~/store'


const {
  Token,
  GemToken
} = require("~/gem-contract/scripts/address.js");

declare var window: any

@Component({  
  layout : 'page'
})
export default class IndexVue extends Vue {
  public protocolStats = [
    {
      icon: require('../assets/img/dashboardIcon/price_icon.svg'),
      title: "$GEM Price",
      price: "0",
      percentage: "0"
    },
    {
      icon: require('../assets/img/dashboardIcon/marketcap_icon.svg'),
      title: "Market Cap",
      price: "0",
      percentage: "0"
    },
    {
      icon: require('../assets/img/dashboardIcon/circsupply_icon.svg'),
      title: "Total Supply",
      price: "500000",
      percentage: "0"
    },
    {
      icon: require('../assets/img/dashboardIcon/totalnode_icon.svg'),
      title: "Total Nodes",
      price: "0",
      percentage: "0"
    },
  ]

   public personalStats = [
    {
      icon: require('../assets/img/dashboardIcon/mynode_icon.svg'),
      title: "My Nodes",
      price: "0",
      percentage: "0"
    },
    {
      icon: require('../assets/img/dashboardIcon/gembalance_icon.svg'),
      title: "My $GEM Balance",
      price: "0",
      percentage: "0"
    },
    {
      icon: require('../assets/img/dashboardIcon/dailyrewards_icon.svg'),
      title: "Daily Rewards",
      price: "0",
      percentage: "0"
    },
    {
      icon: require('../assets/img/dashboardIcon/pendingrewards_icon.svg'),
      title: "Pending Rewards",
      price: "0",
      percentage: "0"
    },
  ]  


  private getFromattedNb(nb : any) : string {
    nb = nb.toLocaleString();
    if (nb.indexOf(".") == -1) return nb;
    else {
      if (nb.indexOf(".") == nb.length - 2)
        return nb.substr(0, nb.indexOf(".") + 2) + "0";
    }
    return nb.substr(0, nb.indexOf(".") + 3);
  }

  public ProtocolData() : void {
    const params = {
      contract_addresses: GemToken,
      vs_currencies : "usd",
      include_market_cap :true,
      include_24hr_vol : true,
      include_24hr_change : true,
      include_last_updated_at : true
    }
    try {
      axios
      .get(
        "https://api.coingecko.com/api/v3/simple/token_price/avalanche", {params : params, headers: {'Access-Control-Allow-Origin' : '*'}}
      )
      .then(
        (response : any) => {
            var keyArray = Object.keys(response.data)            
            console.log(response.data,"marketcap")
            this.protocolStats[0].price = this.getFromattedNb(response.data[keyArray[0]].usd)
            this.protocolStats[0].percentage = this.getFromattedNb (response.data[keyArray[0]].usd_24h_change) 
            let tempPrice = this.getFromattedNb(response.data[keyArray[0]].usd  * 1000000)
            console.log(tempPrice,"tempPrice")
            this.protocolStats[1].price = tempPrice
        }
      );
    } catch {
      console.log('Catch Network')
    }    
  }

  private get loadWalletAddress (): string {
    return WalletModule.walletaddress
  }

  private async personalData() : Promise<void> {
    if (window.ethereum) {
      const ethers = require("ethers");
      const provider = new ethers.providers.Web3Provider(
         window.ethereum,
         "any"
      );

      const signer = provider.getSigner();
      // const userAddress = await signer.getAddress();

      const pnode =new ethers.Contract(Token, NODER, signer);
      const gem = new ethers.Contract(GemToken, GEM, signer);
      // const rewardManage = new ethers.Contract(Reward, NODER, signer);
      
      let tmp = await pnode.getTotalCreatedNodes();
      this.protocolStats[3].price = parseInt(tmp._hex, 16).toString();

      if(WalletModule.walletaddress)
      {
        tmp = await pnode.getTotalCreatedNodesOf(WalletModule.walletaddress);
        this.personalStats[0].price = parseInt(tmp._hex, 16).toString();

        tmp = await gem.balanceOf(WalletModule.walletaddress);
        this.personalStats[1].price =this.getFromattedNb(ethers.utils.formatEther(tmp._hex));
      }       

      //dailyrewards
      tmp = await pnode.getNodeTypesSize();
      let nodeSize = parseInt(tmp._hex, 16);

      let tempNodeName :any= []
      let nodeName : any = []
      let tempCounter :any= []
      let nodeCounter : any = []
      let tempNodeReward :any = []
      let perNodeReward : any = []
      for(let i = 0 ; i < nodeSize ; i++)
        tempNodeName.push(pnode.getNodeTypeNameAtIndex(i))
      await Promise.all(tempNodeName).then((res)=>{
        nodeName = res
      })
      console.log(nodeName,"NodeName")
      for(let i = 0 ; i < nodeSize ; i++)
          tempNodeReward.push(pnode.getNodeTypeAll(nodeName[i]));
      await Promise.all(tempNodeReward).then((res) => {
        for(let index in res)
          perNodeReward[index] = ethers.utils.formatEther(res[index][2]._hex)
      })
      console.log(perNodeReward,"perNodeReward")

      for(let i = 0 ; i < nodeSize ; i++)
      {
          tempCounter.push(pnode.getNodeTypeOwnerNumber(nodeName[i],WalletModule.walletaddress))
      }
      await Promise.all(tempCounter).then((res)=>{
        for(let index in res)
          nodeCounter[index] = parseInt(res[index]._hex, 16)
      })
      console.log(nodeCounter,"NodeCOunter")
      let rewardPerClaim = 0;
      for(let i = 0 ; i <nodeSize ; i++)
      {
         rewardPerClaim += perNodeReward[i]*nodeCounter[i]*6
      }
      console.log(rewardPerClaim,"REwardPER")
      this.personalStats[2].price = this.getFromattedNb(rewardPerClaim);
      
      //pendingrewards
      tmp = await pnode.calculateAllClaimableRewards(WalletModule.walletaddress);
      this.personalStats[3].price = this.getFromattedNb(ethers.utils.formatEther(tmp._hex)) ;
    }
  }

  public intervalFetchData() : void {
    setInterval(() => {
      this.ProtocolData();
      this.personalData();
    }, 5000);
  }

  private async created() : Promise<void> {
    this.ProtocolData();    
    this.personalData();
    this.intervalFetchData();
  }
}
</script>
