<template>
  <div class="wrapper">
    <h2 class="title">现金使用情况问卷调查</h2>
    <group class="content" v-for="(question,i) of questionList" :title="`${i+1}.${question.title}`" :key="question.title">
      <radio :options="question.option" v-model="answerList[i]" @on-change="change"></radio>
    </group>
    <div class="submit">
      <x-button type="primary" @click.native="submit">提交</x-button>
    </div>
    <footer>&copy;cbpm 2017 中国印钞造币总公司</footer>
    <toast v-model="toast.show">{{ toast.msg }}</toast>
  </div>
</template>

<script>
  import {
    Toast,
    Group,
    Radio,
    XButton
  } from 'vux'

  import {
    dateFormat
  } from 'vux'

  import {
    mapState
  } from 'vuex'

  import questionList from '../assets/data/question.json';

  export default {
    components: {
      Toast,
      Group,
      Radio,
      XButton
    },
    data() {
      return {
        toast: {
          show: false,
          msg: ''
        },
        questionList,
        answerList: [],
        isCompleted: false
      }
    },
    computed: {
      ...mapState(['userInfo', 'cdnUrl']),
      url() {
        return window.location.href.split('#')[0];
      }
    },
    methods: {
      getCompleteStatus() {
        let flag = true;
        for (let i = 0; flag && i < this.answerList.length; i++) {
          let item = this.answerList[i];
          if (item == '') {
            flag = false;
          }
        }
        this.isCompleted = flag;
      },
      change() {
        this.getCompleteStatus();
        console.log(this.answerList);
        console.log(this.isCompleted);
      },
      getSubmitData() {
        return {
          nickname: this.userInfo.nickname,
          openid: this.userInfo.openid,
          sex: this.userInfo.sex,
          city: this.userInfo.city,
          province: this.userInfo.province,
          country: this.userInfo.country,
          headimgurl: this.userInfo.headimgurl,
          rec_time: dateFormat(new Date(), 'YYYY-MM-DD HH:mm:ss')
        };
      },
      submit() {
        // let params = this.getSubmitData();

        // params.s = '/addon/Api/Api/setUserComment';

        // this.$http.jsonp(this.cdnUrl, {
        //   params
        // }).then(res => {
        //   this.toast.show = true;
        //   this.toast.msg = res.data.msg;
        // });
        this.toast = {
          show: true,
          msg: '提交成功'
        }
        setTimeout(() => {
          this.$router.push('address');
        }, 1000);
      },
      init() {
        document.title = '现金使用情况问卷调查';
        this.answerList = this.questionList.map(item => '');
      }
    },
    mounted() {
      this.init();
    }
  }

</script>

<style scoped lang="less">
  .wrapper {
    padding: 20px 0;
    .thin {
      font-weight: 100;
    }
    .title {
      font-size: 18pt;
      .thin;
      text-align: center;
      line-height: 60px;
      border-bottom: 1px solid #ccc;
    }
    .content {
      margin: 20px 0;
      padding: 10px;
      color: #444;
      background: #fff;
    }
    .submit {
      margin: 20px;
    }
    footer {
      font-size: 14px;
      color: #999;
      text-align: center;
    }
  }

</style>
