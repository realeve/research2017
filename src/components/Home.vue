<template>
  <div class="wrapper">
    <div class="welcome">
     <img class="user" :src="userInfo.headimgurl">
     <p class="txt">{{userInfo.nickname}}您好,感谢参加本次调查问卷活动,本问卷数据我们只用于对现金使用情况研究,不作它用。<br>问卷填写完毕后系统会自动抽奖，请您认真作答，感谢您的参与。</p>
    </div>
    <div v-for="(question,i) of questionList" :key="question.title">
      <checklist v-if="question.multiply" label-position="left" :title="`${i+1}.${question.title}`" required :options="question.option" v-model="answerList[i]" @on-change="change"></checklist>
      <group v-else class="content" :title="`${i+1}.${question.title}`">
        <radio :options="question.option" v-model="answerList[i]" @on-change="change"></radio>
      </group>
    </div>
    <div class="submit">
      <x-button :disabled="!isCompleted" type="primary" @click.native="submit">提交</x-button>
    </div>
    <toast v-model="toast.show">{{ toast.msg }}</toast>
  </div>
</template>

<script>
import {
  Toast,
  Group,
  Radio,
  Checklist,
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
    Checklist,
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
  watch: {
    answerList(val) {
      this.getCompleteStatus();
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
      // console.log(this.answerList);
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
        rec_time: dateFormat(new Date(), 'YYYY-MM-DD HH:mm:ss'),
        answer: this.answerList
      };
    },
    submit() {
      let params = this.getSubmitData();

      params.s = '/addon/Api/Api/setResearch';

      this.$http.jsonp(this.cdnUrl, {
        params
      }).then(res => {
        this.toast.show = true;
        this.toast.msg = res.data.msg;
        if (res.data.id > 0) {
          // 进入抽奖页面
          this.$router.push('address');
        }
      });
    },
    init(){
      let params = {
        s: '/addon/Api/Api/isResearchAnswered',
        openid:this.userInfo.openid
      }
      this.$http.jsonp(this.cdnUrl, {
        params
      }).then(res => {
        if(res.data[0].num>0){
          this.$router.push('address');
        }else{
          document.title = '现金使用情况问卷调查';
          this.answerList = this.questionList.map(item => item.multiply ? [] : '');
        }
      });      
    }
  },
  mounted() {
    this.init();
  }
}

</script>

<style scoped lang="less">
@import '~vux/src/styles/1px.less';
  @userSize:60px;
.wrapper {
  padding: 0 0 20px 0;
  .thin {
    font-weight: 100;
  }
  .title {
    font-size: 18pt;
    .thin;
    text-align: center;
    line-height: 60px; // border-bottom: 1px solid #ccc;
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
  .welcome{
    padding:30px 0 0 15px;
    display: flex;
    flex-direction: row;
    .user{
      width: @userSize;
      height: @userSize;
      border-radius: 50%;
    }
    .txt{
      padding-left:20px;
      font-size: 11pt;
      color:#555;
    }
  }
}
</style>
