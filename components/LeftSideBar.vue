<template>
    <v-navigation-drawer
      left
      app
      width="244px"
      class="bg-[#2A0D40] rounded-l-[16px] w-[244px] h-[100%] bg-position"
      :src="require('../assets/img/page-bg.jpg')"
      v-model="drawer"
      :permanent="$vuetify.breakpoint.mdAndUp"
      
    >
      <div>
        <v-list>
          <img class="mt-[44px] mb-[20px] md:mb-[100.3px] mx-[0px] " :src="require('../assets/img/imagotipo.png')" style="width:230px;height:45px;" alt="">
          <v-list-item
            active-class="menu-button"
            class="hover:bg-[#8D1954] w-[188px] h-[46px] rounded-[10px] mx-[28px] mb-[14px] md:mb-[30px] active:bg-[#00c6ed]"
            v-for="(item, i) in core"
            :key="i"
            :to="item.to"
            :href="item.href"
            :target="item.target"

          >
            <img class="mx-[23.5px]" :src="item.url" alt="">
            <v-list-item-content>
              <v-list-item-title v-text="item.title" class="text-white text-[14px]" />
            </v-list-item-content>
          </v-list-item>
        </v-list>
        <div class="hidden-md-and-up">
          <ConnectionBtn/>
        </div>
      </div>
    <div class="mb-6">
      <div class="ml-[24px] mb-[14px] md:mb-[28px] icon-filter">
          <a  href="https://twitter.com/gem_nodes" target="_blank">
            <div class="flex flex-row mx-[41.5px]">
              <img class="mr-[10px]" :src="require('../assets/img/contact.svg')" alt="">
              <span class="text-white text-[14px]">Follow Us!</span>
            </div>
          </a>
      </div>
      <div class="ml-[24px] mb-[14px] md:mb-[28px] icon-filter">
          <a  href="https://discord.com/invite/gemnodes" target="_blank">
            <div class="flex flex-row mx-[41.5px]">
              <img class="mr-[10px]" :src="require('../assets/img/discord.svg')" alt="">
              <span class="text-white text-[14px]">Join Discord</span>
            </div>
          </a>
      </div>
      <!--
      <div class="ml-[24px] mb-[14px] md:mb-[28px]">
          <a  href="https://dexscreener.com/avalanche/0x6c1c0319d8ddcb0ffe1a68c5b3829fd361587db4 " target="_blank">
            <div class="flex flex-row mx-[41.5px]">
              <img class="mr-[10px]" :src="require('../assets/img/gemchart.svg')" alt="">
              <span class="text-white text-[14px]">$GEM Chart</span>
            </div>
          </a>
      </div> -->
      <!-- 
      <div class="ml-[24px] mb-[14px] md:mb-[28px] icon-filter">
          <a  href="https://snapshot.org/#/gemnodes.eth" target="_blank">
            <div class="flex flex-row mx-[41.5px]">
              <img class="mr-[10px] w-[24px] h-[24px]" :src="require('../assets/img/governanceIcon.svg')" alt="">
              <span class="text-white text-[14px]">Governance</span>
            </div>
          </a>
      </div>-->
    </div>
  </v-navigation-drawer>
</template>
<script lang="ts">
import { mapGetters } from "vuex"
import { Component, Vue } from 'nuxt-property-decorator'

@Component
export default class LeftSideBar extends Vue {
    public drawer = false    

    public core = [
        {
          url: require('../assets/img/homeIcon.svg'),
          title: "Dashboard",
          to: "/",
        },
        {
          url: require('../assets/img/nodesIcon.svg'),
          title: "Nodes",
          to: "/nodes",
        },
    ]
        
    created() {
      this.$root.$refs.draw = this;

    }
    
    private async Draw (): Promise<void> {
        this.drawer = !this.drawer;
    }
}
</script>

<style scoped>
  .menu-button{
    background-color: rgba(19, 0, 97, 0.3);
    border-radius: 1.75rem;
    font-weight: bold;
    border-style: none;
  }
  .menu-button-hvr{
    background: #f2709c;
    background: -webkit-linear-gradient(to right, #ff9472, #f2709c);
    background: linear-gradient(to right, #ff9472, #f2709c);
  }
  .icon-filter{
    filter: brightness(0) invert(1);
  }
  .bg-position{
    background-position: top center !important;
  }
</style>