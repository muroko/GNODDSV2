<template>
<div class='overflow-x-auto w-full'>
    <table class='mx-auto w-full whitespace-nowrap rounded-lg bg-[#17171B]  overflow-hidden'>
        <thead>
          <tr class="text-white text-left bg-[#8D1954]">
              <th class="p-[16px]">My Nodes</th>
              <th></th>
              <th></th>
              <th></th>
              <th></th>
              <th></th>
          </tr>
          <tr>
            <th class="pl-[16px] pt-[12px] text-left  ">
              <button  class="text-center text-white font-normal text-[16px] border-solid border-[#8D1954] border-[1px] hover:bg-[#00C6ED] rounded-[14px] px-[30%] my-[10px] token-button" @click="rewardClaim">
                <div>
                  Claim Rewards
                </div>          
              </button>
            </th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
            <th></th>
          </tr>
          <tr>
            <th class="w-[20%] pt-[12px] pl-[16px] text-left text-[12px]">
                <span class="text-[#D5D83D]">Node Level</span>
            </th>       
            <th class="w-[30%] pt-[12px] pl-[16px] text-left text-[12px]">
                <span class="text-[#D5D83D]">Node Type</span>
            </th>
            <th class="w-[20%] pt-[12px] pl-[16px] text-left text-[12px]">
                <span class="text-[#D5D83D]">Node Counter</span>
            </th>
            <th class="pt-[12px] pl-[16px] text-left text-[12px]">
                <!-- <span class="text-[#00c6ed]">Last Claim</span> -->
            </th>
            <th class="pt-[12px] pl-[16px] text-left text-[12px]">
                <!-- <span class="text-[#00c6ed]">Claimed Rewards</span> -->
            </th>
            <th class="pt-[12px] pl-[16px] text-left text-[12px]">
                <!-- <span class="text-[#00c6ed]">Pending Rewards</span> -->
            </th>
          </tr>
        </thead>
        <tbody class="divide-white/10 divide-y-[1px] px-[16px]">
          <tr v-for="(item, i) in nodeData">
            <td class="w-[20%] py-[12px] pl-[16px] text-left text-[12px] text-white">
              {{item.nodeIndex}}
            </td>
            <td class="w-[30%] py-[12px] pl-[16px] text-left text-[12px] text-white">
              {{item.nodeType}}
            </td>
              <td class="w-[20%] py-[12px] pl-[16px] text-left text-[12px] text-white">
              {{item.nodeCounter}}
            </td>

              <td class="py-[12px] pl-[16px] text-left text-[12px] text-white">
              <!-- {{item.lastClaim}} -->
            </td>
              <td class="py-[12px] pl-[16px] text-left text-[12px] text-white">
             <!-- {{item.claimRewards}} -->
            </td>
              <td class="py-[12px] pl-[16px] text-left text-[12px] text-white">
             <!-- {{item.pendingRewards}} -->
            </td>
          </tr>
        </tbody>
    </table>
</div>
</template>
<script lang="ts">
import { Component, Prop, Vue } from 'nuxt-property-decorator'

import { abi as NODER } from "~/gem-contract/artifacts/contracts/NODERewardManager.sol/NODERewardManager.json";
import Default from "~/layouts/default.vue"

const {
  Token,
} = require("~/gem-contract/scripts/address.js");

declare var window: any

@Component({
  props:{
    items:Array
  }
})
export default class NodeTable extends Vue {
  
  private nodeData = []

  private created() {
    this.nodeData = this.$props.items;
  }

  private async rewardClaim() : Promise<void> {
    const ethers = require("ethers");
    if (window.ethereum) {
      const ethers = require("ethers");
      const provider = new ethers.providers.Web3Provider(
         window.ethereum,
         "any"
      );
      const signer = provider.getSigner();
      const userAddress = await signer.getAddress();
      const pnode =new ethers.Contract(Token, NODER, signer);

      try {
        
        await pnode.cashoutAll();
      }
      catch(err:any)
      {
        if (err.data.message.indexOf("GET REWARD OF: NO NODE OWNER") >= 0) {
           (this.$root.$refs.alert as Default).NoOwner();
          return;
        }
        if (err.data.message.indexOf("MANIA CSHT: Blacklisted address") >= 0) {
           (this.$root.$refs.alert as Default).NodesBlacklist();
          return;
        }

        if (err.data.message.indexOf("MANIA CSHT:  creation from the zero address") >= 0) {
           (this.$root.$refs.alert as Default).MustSign();
          return;
        }

        if (err.data.message.indexOf("MANIA CSHT: treasury and rewardsPool cannot cashout rewards") >= 0) {
           (this.$root.$refs.alert as Default).MustSign();
          return;
        }

        if (err.data.message.indexOf("MANIA CSHT: You don't have enough reward to cash out") >= 0) {
           (this.$root.$refs.alert as Default).MustSign();
          return;
        }

        if (err.data.message.indexOf("Nothing to claim") >= 0) {
           (this.$root.$refs.alert as Default).NoClaim();
          return;
        }
      }
    }
  }
}
</script>

<style scoped>
  .token-button{
    background: #f2709c;
    background: -webkit-linear-gradient(to right, #ff9472, #f2709c);
    background: linear-gradient(to right, #ff9472, #f2709c);
  }
</style>