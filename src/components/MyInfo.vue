<template>
  <div class="home">
    <form-preview header-label="用户信息预览" :header-value="username+'(收)'" :body-items="list"></form-preview>
    <div class="box">
      <group title="姓名">
        <x-input title="姓名" name="username" v-model="username" placeholder="请输入姓名" is-type="china-name"></x-input>
      </group>

      <group title="手机号码">
        <x-input title="手机号码" name="mobile" v-model="mobile" placeholder="请输入手机号码" keyboard="number" is-type="china-mobile"></x-input>
      </group>

      <group>
        <x-address title="省/市" raw-value v-model="addressArr" :list="addressData" inline-desc="点击设置地址"></x-address>
        <x-input title="详细地址" name="address_detail" v-model="address_detail" placeholder="请输入详细信息"></x-input>
      </group>


      <div class="submit">
        <x-button type="primary" plain @click.native="submit">提交信息</x-button>
        <x-button plain @click.native="viewHome">返回首页</x-button>
      </div>
    </div>

    <div class="center footer">
      cbpc &copy; 2017 成都印钞有限公司
    </div>

    <toast v-model="toast.show">{{ toast.msg }}</toast>
  </div>
</template>

<script>
  import {
    XButton,
    XInput,
    Group,
    Cell,
    dateFormat,
    Toast,
    XAddress,
    ChinaAddressV3Data,
    Value2nameFilter as value2name,
    FormPreview
  } from 'vux'

  import {
    mapState
  } from 'vuex'

  export default {
    components: {
      XButton,
      XInput,
      Group,
      Cell,
      Toast,
      XAddress,
      FormPreview
    },
    data() {
      return {
        username: '',
        mobile: '',
        toast: {
          show: false,
          msg: ''
        },
        addressArr: ['四川省', '成都市', '温江区'],
        addressData: ChinaAddressV3Data,
        address_detail: ''
      }
    },
    computed: {
      ...mapState(['userInfo', 'cdnUrl']),
      address() {
        return value2name(this.addressArr, ChinaAddressV3Data)
      },
      list() {
        return [{
          label: '手机',
          value: this.mobile
        }, {
          label: '省/市',
          value: this.address
        }, {
          label: '详细地址',
          value: this.address_detail
        }];
      }
    },
    methods: {
      now() {
        return dateFormat(new Date(), 'YYYY-MM-DD HH:mm:ss');
      },
      submit() {
        let params = {
          s: '/addon/Api/Api/setLuckyUserInfo',
          username: this.username,
          mobile: this.mobile,
          address:this.address,
          address_detail:this.address_detail,
          rec_time: this.now(),
          openid: this.userInfo.openid,
        }
        this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res => {
          this.toast.show = true;
          this.toast.msg = res.data.msg;
        })
      },
      loadDefaultData(){        
        let params = {
          s: '/addon/Api/Api/getLuckyUserDefaultInfo',
          openid: this.userInfo.openid,
        }
        this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res => {
          let obj = res.data[0];
          if(typeof obj =='undefined' || !Reflect.get(obj,'username')){
            return;
          }
          this.username = obj.username;
          this.mobile = obj.mobile;
          this.addressArr = obj.address.split(' ');
          this.address_detail = obj.address_detail
        });
      },
      viewHome() {
        this.$router.push('/');
      },
      isTrueUrl(){
        if(!this.userInfo.openid){
          window.location.href = window.location.href.split('?')[0];
          return;
        }
        let params = {
          s: '/addon/Api/Api/isLuckyUser',
          openid: this.userInfo.openid,
        }
        this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res=>{
          if(res.data[0].num==0){
            this.viewHome();
          }
        })
      },
      init() {
        this.isTrueUrl();
        document.title = '个人信息';
        this.loadDefaultData();
      }
    },
    mounted() {
      this.init();
    }
  }

</script>

<style scoped lang="less">
  .home {
    margin-top: 10%;
    height: 100%;
    font-weight: 100;
    .title {
      font-size: 13pt;
    }
    .footer {
      color: #233;
      padding: 10px 0;
      font-size: 10pt;
    }
    .box {
      margin-top: 40px;
      min-height: 350px;
    }
    .center {
      display: flex;
      justify-content: center;
    }
    .submit {
      padding: 30px 20px;
    }
  }

</style>
