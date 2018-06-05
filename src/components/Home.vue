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
import { Toast, Group, Radio, Checklist, XButton } from "vux";

import { dateFormat } from "vux";

import { mapState } from "vuex";
import md5 from "md5";

// import questionList from "../assets/data/question.json";
import questionList from "../assets/data/reject.json";

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
        msg: ""
      },
      time: new Date().getTime(),
      questionList,
      answerList: [],
      isCompleted: false
    };
  },
  computed: {
    ...mapState(["userInfo", "cdnUrl", "sport"]),
    url() {
      return window.location.href.split("#")[0];
    },
    openid() {
      return this.userInfo.openid;
    }
  },
  watch: {
    answerList(val) {
      this.getCompleteStatus();
    }
  },
  methods: {
    getSignature() {
      this.time = new Date().getTime();
      this.signature = md5(
        btoa(
          this.sport.salt + this.time + this.openid + this.openid.toUpperCase()
        )
      );
    },
    getCompleteStatus() {
      let flag = true;
      for (let i = 0; flag && i < this.answerList.length; i++) {
        let item = this.answerList[i];
        if (item == "") {
          flag = false;
        }
      }
      this.isCompleted = flag;
    },
    change() {
      // console.log(this.answerList);
    },
    getSubmitData() {
      this.getSignature();
      return {
        s: "/addon/Api/Api/addAnswerInfo",
        sid: this.sport.id,
        timestamp: this.time,
        signature: this.signature,
        addstr: this.convertAnswers(), //this.answerList.join(","),
        openid: this.userInfo.openid,
        nickname: this.userInfo.nickname,
        sex: this.userInfo.sex,
        city: this.userInfo.city,
        province: this.userInfo.province,
        country: this.userInfo.country,
        headimgurl: this.userInfo.headimgurl
      };
    },
    convertAnswers() {
      let answers = [];
      this.answerList.map((item, idx) => {
        let question = questionList[idx].option;
        let curAnswer = [];
        question.forEach((answer, i) => {
          if (item.includes(answer)) {
            curAnswer.push(i);
          }
        });
        answers.push(curAnswer.join(","));
      });

      // 将所有题目选项答案连接
      return answers.map(item => `'${item}'`).join(",");
    },
    submit() {
      let params = this.getSubmitData();

      // params.s = "/addon/Api/Api/setResearch";
      this.$http
        .jsonp(this.cdnUrl, {
          params
        })
        .then(res => {
          this.toast.show = true;
          this.toast.msg = res.data.msg;
          if (res.data.status == 1) {
            // 进入抽奖页面
            this.$router.push("address");
          }
        })
        .catch(e => {
          console.log(e);
        });
    },
    auth() {
      if (this.userInfo.openid == null || location.href.indexOf("from=") > 0) {
        this.$router.push("/follow");
        return false;
      }
      return true;
    },
    init() {
      let passed = this.auth();
      if (!passed) {
        return;
      }

      let params = {
        // s: "/addon/Api/Api/isSetUserInfo",
        s: "/addon/Api/Api/getResearchStatus",
        openid: this.openid,
        sid: this.sport.id
      };
      this.$http
        .jsonp(this.cdnUrl, {
          params
        })
        .then(res => {
          // if (res.data.status > 1) {
          //   // 进入抽奖页面
          //   this.$router.push("address");
          // } else {
          //   document.title = "现金使用情况调查问卷";
          //   this.answerList = this.questionList.map(
          //     item => (item.multiply ? [] : "")
          //   );
          // }

          if (res.data[0].num > 0) {
            // 进入抽奖页面
            this.$router.push("address");
          } else {
            document.title = "现金使用情况调查问卷";
            this.answerList = this.questionList.map(
              item => (item.multiply ? [] : "")
            );
          }
        });
    }
  },
  mounted() {
    this.init();
  }
};
</script>

<style scoped lang="less">
@import "~vux/src/styles/1px.less";
@userSize: 60px;
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
  .welcome {
    padding: 30px 0 0 15px;
    display: flex;
    flex-direction: row;
    .user {
      width: @userSize;
      height: @userSize;
      border-radius: 50%;
    }
    .txt {
      padding-left: 20px;
      font-size: 11pt;
      color: #555;
    }
  }
}
</style>
