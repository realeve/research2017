<template>
  <div id="app">
    <loading v-model="isLoading"></loading>
    <router-view></router-view>
  </div>
</template>

<script>
  import {
    Loading
  } from 'vux'

  import {
    querystring
  } from 'vux'

  import {
    mapState
  } from 'vuex'
  export default {
    name: 'app',
    components: {
      Loading
    },
    data() {
      return {
        code: '',
        apiId: 'wx0d9af88bd9613e6a',
      }
    },
    computed: {
      ...mapState(['isLoading', 'cdnUrl']),
      userInfo: {
        get() {
          return this.$store.state.userInfo;
        },
        set(val) {
          this.$store.commit('setUserinfo', val);
        }
      },
      // 签名用URL
      url() {
        return window.location.href.split('#')[0];
      },
      // 跳转URL
      redirectUrl() {
        return `https://open.weixin.qq.com/connect/oauth2/authorize?appid=${this.apiId}&redirect_uri=${encodeURIComponent(this.url)}&response_type=code&scope=snsapi_userinfo&state=1#wechat_redirect`;
      },
      shareUrl() {
        // 被分享的链接必须在安全域名中，不能直接分享为 redirectUrl
        return window.location.href.split('#')[0].split('?')[0];
      }
    },
    methods: {
      wxPermissionInit() {
        let params = {
          s: '/addon/Api/Api/getSignature',
          url: this.url
        }
        return this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res => res.data);
      },
      wxReady(obj) {
        this.$wechat.config({
          debug: false,
          appId: obj.appId,
          timestamp: obj.timestamp,
          nonceStr: obj.nonceStr,
          signature: obj.signature,
          jsApiList: [
            'onMenuShareAppMessage', 'onMenuShareTimeline', 'onMenuShareQQ', 'onMenuShareWeibo',
            'onMenuShareQZone', 'hideMenuItems'

          ]
        })
      },
      initWxShare() {
        this.$wechat.ready(() => {
          let option = {
            title: '现金使用情况有奖调查', // 分享标题
            desc: '现金使用情况有奖调查',
            link: this.shareUrl,
            imgUrl: 'http://cbpm.sinaapp.com/cdn/logo/cbpm.jpg',
            type: '',
            dataUrl: '',
            success: function () {},
            cancel: function () {}
          };
          this.$wechat.onMenuShareAppMessage(option);
          this.$wechat.onMenuShareTimeline(option);
          this.$wechat.onMenuShareQQ(option);
          this.$wechat.onMenuShareWeibo(option);
          this.$wechat.onMenuShareQZone(option);

          // 要隐藏的菜单项，只能隐藏“传播类”和“保护类”按钮，所有menu项见附录3
          this.$wechat.hideMenuItems({
            menuList: ["menuItem:editTag", "menuItem:delete", "menuItem:copyUrl", "menuItem:originPage",
              "menuItem:readMode", "menuItem:openWithQQBrowser", "menuItem:openWithSafari",
              "menuItem:share:email"
            ]
          });
        });
      },
      // 获取微信用户信息（昵称，地区）
      getWXUserInfo() {
        let userInfo;
        let wx_userinfo = localStorage['wx_userinfo'];
        if (typeof wx_userinfo != 'undefined') {
          userInfo = JSON.parse(wx_userinfo);
          this.userInfo = userInfo;
          return;
        }
        this.getWXInfo();
      },
      getWXInfo() {
        let params = {
          s: '/addon/Api/Api/getUserInfo',
          code: this.code
        }
        this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res => {
          this.userInfo = res.data;
          if (Reflect.get(res.data, 'nickname')) {
            localStorage.setItem('wx_userinfo', JSON.stringify(res.data));
          }
        });
      },
      wxInit() {
        if (!this.needRedirect()) {
          this.getWXUserInfo();
        }
        this.wxPermissionInit().then(res => {
          this.wxReady(res);
          this.initWxShare();
          this.recordReadNum();
        })
      },
      needRedirect() {
        let params = querystring.parse(window.location.href.split('?')[1]);
        if (!Reflect.get(params, 'code')) {
          window.location.href = this.redirectUrl;
          return true;
        }
        this.code = params.code;
        console.log(this.redirectUrl);
        return false;
      },
      recordReadNum() {
        let url = window.location.href.split("?")[0];
        let params = {
          s: '/addon/Api/Api/recordReadNum',
          url
        }
        this.$http.jsonp(this.cdnUrl, {
          params
        }).then(res => {
          console.log(res.data);
        });
      }
    },
    created() {
      // 开发模式下，初始化值
      if (process.env.NODE_ENV == 'development') {
        this.userInfo = {
          "openid": "o6lf8vuuvwwolqpAGPOG_MdMHaKM",
          "nickname": "宾不厌诈",
          "sex": 1,
          "language": "zh_CN",
          "city": "成都",
          "province": "四川",
          "country": "中国",
          "headimgurl": "http://wx.qlogo.cn/mmopen/Q3auHgzwzM5pR1A0Hxo7ibPnxQib1jibiaBSAOW0s3noCngvI4R8nNFf4sXldyyecaM5UZ4eGC9oZicAicM9XndXHBdQ87sFJzV56ebv84KqJHuZs/0",
          "privilege": []
        }
      } else {
        // 正式环境微信载入
        this.wxInit();
      }
    }
  }

</script>

<style lang="less">
  @import '~vux/src/styles/reset.less';

  body {
    background-color: #f9f9f9;
  }

  .weui-cells__title {
    color: #444!important;
    font-size: 16px!important;
    margin-top:0!important;
  }

</style>
